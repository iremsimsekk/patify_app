package com.patify.api.auth;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

  private final UserRepository users;
  private final PasswordEncoder encoder;
  private final JwtService jwt;

  public AuthController(UserRepository users, PasswordEncoder encoder, JwtService jwt) {
    this.users = users;
    this.encoder = encoder;
    this.jwt = jwt;
  }

  // ✅ Register artık ad/soyad da alıyor
  public record RegisterReq(String email, String password, String firstName, String lastName) {}
  public record LoginReq(String email, String password) {}

  // ✅ Response artık profil bilgilerini de döndürüyor
  public record AuthRes(String token, String role, String email, String firstName, String lastName) {}

  @PostMapping("/register")
  public AuthRes register(@RequestBody RegisterReq req) {
    String email = req.email().toLowerCase().trim();
    if (users.findByEmail(email).isPresent()) throw new RuntimeException("EMAIL_EXISTS");

    User u = new User();
    u.email = email;
    u.passwordHash = encoder.encode(req.password());
    u.role = Role.USER;

    // boşlukları temizleyelim
    u.firstName = req.firstName() != null ? req.firstName().trim() : null;
    u.lastName  = req.lastName()  != null ? req.lastName().trim()  : null;

    users.save(u);

    return new AuthRes(
      jwt.createToken(u.email, u.role),
      u.role.name(),
      u.email,
      u.firstName,
      u.lastName
    );
  }

  @PostMapping("/login")
  public AuthRes login(@RequestBody LoginReq req) {
    String email = req.email().toLowerCase().trim();
    User u = users.findByEmail(email).orElseThrow(() -> new RuntimeException("INVALID"));

    if (!encoder.matches(req.password(), u.passwordHash)) throw new RuntimeException("INVALID");

    return new AuthRes(
      jwt.createToken(u.email, u.role),
      u.role.name(),
      u.email,
      u.firstName,
      u.lastName
    );
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
    u.lastName  = lastName  != null ? lastName.trim()  : null;

    users.save(u);
    return "admin seeded";
  }

}
