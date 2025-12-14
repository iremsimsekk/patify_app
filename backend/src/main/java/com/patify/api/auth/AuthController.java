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

  public record RegisterReq(String email, String password) {}
  public record LoginReq(String email, String password) {}
  public record AuthRes(String token, String role) {}

  @PostMapping("/register")
  public AuthRes register(@RequestBody RegisterReq req) {
    String email = req.email().toLowerCase().trim();
    if (users.findByEmail(email).isPresent()) throw new RuntimeException("EMAIL_EXISTS");

    User u = new User();
    u.email = email;
    u.passwordHash = encoder.encode(req.password());
    u.role = Role.USER;
    users.save(u);

    return new AuthRes(jwt.createToken(u.email, u.role), u.role.name());
  }

  @PostMapping("/login")
  public AuthRes login(@RequestBody LoginReq req) {
    String email = req.email().toLowerCase().trim();
    User u = users.findByEmail(email).orElseThrow(() -> new RuntimeException("INVALID"));

    if (!encoder.matches(req.password(), u.passwordHash)) throw new RuntimeException("INVALID");

    return new AuthRes(jwt.createToken(u.email, u.role), u.role.name());
  }

  @PostMapping("/seed-admin")
  public String seedAdmin(@RequestParam(defaultValue = "admin@patify.com") String email,
                          @RequestParam(defaultValue = "Admin123!") String password) {
    String e = email.toLowerCase().trim();
    if (users.findByEmail(e).isPresent()) return "admin exists";

    User u = new User();
    u.email = e;
    u.passwordHash = encoder.encode(password);
    u.role = Role.ADMIN;
    users.save(u);
    return "admin seeded";
  }

}
