package com.patify.api.auth;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/auth")
public class AuthController {
  private static final Logger log = LoggerFactory.getLogger(AuthController.class);

  private final UserRepository users;
  private final PasswordEncoder encoder;
  private final JwtService jwt;
  private final EmailVerificationService emailVerificationService;

  public AuthController(
      UserRepository users,
      PasswordEncoder encoder,
      JwtService jwt,
      EmailVerificationService emailVerificationService
  ) {
    this.users = users;
    this.encoder = encoder;
    this.jwt = jwt;
    this.emailVerificationService = emailVerificationService;
  }

  public record RegisterReq(
      String email,
      String password,
      String firstName,
      String lastName,
      Role role
  ) {}
  public record LoginReq(String email, String password) {}
  public record ResendVerificationReq(String email) {}
  public record UpdateProfileReq(String email, String firstName, String lastName) {}
  public record ChangePasswordReq(String email, String currentPassword, String newPassword) {}

  public record AuthRes(String token, String role, String email, String firstName, String lastName) {}
  public record RegisterRes(String email, String role, String message) {}
  public record MessageRes(String message) {}

  @Transactional
  @PostMapping("/register")
  public RegisterRes register(@RequestBody RegisterReq req) {
    String email = req.email().toLowerCase().trim();
    log.info("[auth][register] requested email={}", email);
    if (users.findByEmail(email).isPresent()) {
      log.info("[auth][register] email already exists email={}", email);
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "EMAIL_EXISTS");
    }

    User u = new User();
    u.email = email;
    u.passwordHash = encoder.encode(req.password());
    u.role = req.role() != null ? req.role() : Role.USER;
    u.firstName = req.firstName() != null ? req.firstName().trim() : null;
    u.lastName = req.lastName() != null ? req.lastName().trim() : null;
    u.emailVerified = false;

    users.save(u);
    log.info(
        "[auth][register] saved user id={} email={} role={} emailVerified={}",
        u.id,
        u.email,
        u.role,
        u.emailVerified
    );
    emailVerificationService.createAndSend(u);
    return new RegisterRes(u.email, u.role.name(), "VERIFICATION_EMAIL_SENT");
  }

  @GetMapping("/verify-email")
  public ResponseEntity<String> verifyEmail(@RequestParam(required = false) String token) {
    log.info("[auth][verify-email] verification requested");
    try {
      emailVerificationService.verify(token);
      return htmlResponse(
          HttpStatus.OK,
          "E-posta adresin doğrulandı",
          "E-posta adresin başarıyla doğrulandı.",
          "Artık uygulamaya geri dönüp giriş yapabilirsin.",
          true
      );
    } catch (ResponseStatusException ex) {
      return htmlResponse(
          ex.getStatusCode(),
          "Doğrulama bağlantısı geçersiz",
          verificationErrorTitle(ex.getReason()),
          verificationErrorDescription(ex.getReason()),
          false
      );
    }
  }

  @PostMapping("/resend-verification")
  public MessageRes resendVerification(@RequestBody ResendVerificationReq req) {
    String email = req.email() != null ? req.email().toLowerCase().trim() : "";
    log.info("[auth][resend-verification] requested email={}", email);
    emailVerificationService.resend(email);
    return new MessageRes("VERIFICATION_EMAIL_RESEND_ACCEPTED");
  }

  @PostMapping("/login")
  public AuthRes login(@RequestBody LoginReq req) {
    String email = req.email().toLowerCase().trim();
    log.info("[auth][login] requested email={}", email);
    User u = users.findByEmail(email).orElseThrow(
      () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID")
    );
    log.info(
        "[auth][login] found user id={} email={} role={} emailVerified={}",
        u.id,
        u.email,
        u.role,
        u.emailVerified
    );

    if (!encoder.matches(req.password(), u.passwordHash)) {
      log.info("[auth][login] invalid password userId={} email={}", u.id, u.email);
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID");
    }

    if (!u.emailVerified) {
      log.info("[auth][login] blocked unverified userId={} email={}", u.id, u.email);
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "EMAIL_NOT_VERIFIED");
    }

    log.info("[auth][login] success userId={} email={}", u.id, u.email);
    return toAuthRes(u);
  }

  @PostMapping("/profile")
  public AuthRes updateProfile(@RequestBody UpdateProfileReq req) {
    String email = req.email().toLowerCase().trim();
    User u = users.findByEmail(email).orElseThrow(
      () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "EMAIL_NOT_FOUND")
    );

    String firstName = req.firstName() != null ? req.firstName().trim() : "";
    String lastName = req.lastName() != null ? req.lastName().trim() : "";

    if (firstName.isBlank() || lastName.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "NAME_REQUIRED");
    }

    u.firstName = firstName;
    u.lastName = lastName;
    users.save(u);

    return toAuthRes(u);
  }

  @PostMapping("/change-password")
  public String changePassword(@RequestBody ChangePasswordReq req) {
    String email = req.email().toLowerCase().trim();
    User u = users.findByEmail(email).orElseThrow(
      () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "EMAIL_NOT_FOUND")
    );

    if (!encoder.matches(req.currentPassword(), u.passwordHash)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_PASSWORD");
    }

    String newPassword = req.newPassword() != null ? req.newPassword().trim() : "";
    if (newPassword.length() < 6) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "PASSWORD_TOO_SHORT");
    }

    u.passwordHash = encoder.encode(newPassword);
    users.save(u);
    return "OK";
  }

  @PostMapping("/seed-admin")
  public String seedAdmin(
      @RequestParam(defaultValue = "admin@patify.com") String email,
      @RequestParam(defaultValue = "Admin123!") String password,
      @RequestParam(defaultValue = "Admin") String firstName,
      @RequestParam(defaultValue = "User") String lastName
  ) {
    String e = email.toLowerCase().trim();
    if (users.findByEmail(e).isPresent()) return "admin exists";

    User u = new User();
    u.email = e;
    u.passwordHash = encoder.encode(password);
    u.role = Role.ADMIN;
    u.firstName = firstName != null ? firstName.trim() : null;
    u.lastName = lastName != null ? lastName.trim() : null;
    u.emailVerified = true;

    users.save(u);
    return "admin seeded";
  }

  private AuthRes toAuthRes(User user) {
    return new AuthRes(
      jwt.createToken(user.email, user.role),
      user.role.name(),
      user.email,
      user.firstName,
      user.lastName
    );
  }

  private ResponseEntity<String> htmlResponse(
      org.springframework.http.HttpStatusCode status,
      String pageTitle,
      String title,
      String description,
      boolean success
  ) {
    String accent = success ? "#6E9A7A" : "#C56D63";
    String soft = success ? "#E6F1E9" : "#F8E7E4";
    String icon = success ? "✓" : "!";
    String html = """
        <!doctype html>
        <html lang="tr">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>%s | Patify</title>
          <style>
            :root {
              color-scheme: light;
              font-family: Arial, Helvetica, sans-serif;
              background: #F6F1EA;
              color: #2F2A28;
            }
            body {
              margin: 0;
              min-height: 100vh;
              display: grid;
              place-items: center;
              padding: 24px;
              box-sizing: border-box;
            }
            .card {
              width: min(100%%, 440px);
              background: #FFFCF8;
              border: 1px solid #E7DED5;
              border-radius: 20px;
              padding: 32px 28px;
              box-shadow: 0 16px 48px rgba(47, 42, 40, 0.08);
              text-align: center;
            }
            .brand {
              margin: 0 0 20px;
              font-size: 28px;
              font-weight: 800;
              color: #CA7B68;
            }
            .icon {
              width: 56px;
              height: 56px;
              margin: 0 auto 18px;
              display: grid;
              place-items: center;
              border-radius: 18px;
              background: %s;
              color: %s;
              font-size: 32px;
              font-weight: 800;
            }
            h1 {
              margin: 0 0 10px;
              font-size: 24px;
              line-height: 1.25;
            }
            p {
              margin: 0;
              color: #6B625D;
              font-size: 15px;
              line-height: 1.55;
            }
            .hint {
              margin-top: 10px;
            }
          </style>
        </head>
        <body>
          <main class="card">
            <p class="brand">Patify</p>
            <div class="icon" aria-hidden="true">%s</div>
            <h1>%s</h1>
            <p>%s</p>
            <p class="hint">%s</p>
          </main>
        </body>
        </html>
        """.formatted(pageTitle, soft, accent, icon, title, description, success
        ? ""
        : "Lütfen uygulamadan tekrar doğrulama e-postası iste.");

    return ResponseEntity.status(status)
        .contentType(MediaType.parseMediaType("text/html; charset=UTF-8"))
        .body(html);
  }

  private String verificationErrorTitle(String reason) {
    if ("VERIFICATION_TOKEN_USED".equals(reason)) {
      return "Bu bağlantı daha önce kullanılmış.";
    }
    if ("VERIFICATION_TOKEN_EXPIRED".equals(reason)) {
      return "Bu doğrulama bağlantısının süresi dolmuş.";
    }
    return "Bu doğrulama bağlantısı geçersiz olabilir.";
  }

  private String verificationErrorDescription(String reason) {
    if ("VERIFICATION_TOKEN_USED".equals(reason)) {
      return "E-posta adresin zaten doğrulanmış olabilir.";
    }
    if ("VERIFICATION_TOKEN_EXPIRED".equals(reason)) {
      return "Güvenliğin için doğrulama bağlantıları belirli bir süre sonra geçerliliğini yitirir.";
    }
    return "Bağlantı eksik, hatalı veya artık geçerli olmayabilir.";
  }
}
