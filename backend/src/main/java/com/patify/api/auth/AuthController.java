package com.patify.api.auth;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
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

  public record RegisterReq(String email, String password, String firstName, String lastName) {}
  public record LoginReq(String email, String password) {}
  public record UpdateProfileReq(String email, String firstName, String lastName) {}
  public record ChangePasswordReq(String email, String currentPassword, String newPassword) {}

  public record AuthRes(String token, String role, String email, String firstName, String lastName) {}
  public record RegisterRes(String email, String message) {}

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
    u.role = Role.USER;
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
    return new RegisterRes(u.email, "VERIFICATION_EMAIL_SENT");
  }

  @GetMapping("/verify-email")
  public String verifyEmail(@RequestParam String token) {
    log.info("[auth][verify-email] verification requested");
    emailVerificationService.verify(token);
    return "EMAIL_VERIFIED";
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
}
