package com.patify.api.auth;

import io.jsonwebtoken.JwtException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthContextService {
  private final JwtService jwtService;
  private final UserRepository users;

  public AuthContextService(JwtService jwtService, UserRepository users) {
    this.jwtService = jwtService;
    this.users = users;
  }

  public User requireAuthenticatedUser(String authorizationHeader) {
    String token = extractBearerToken(authorizationHeader);
    final String email;
    try {
      email = jwtService.extractEmail(token);
    } catch (JwtException | IllegalArgumentException ex) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "INVALID_AUTH_TOKEN");
    }

    return users.findByEmail(email.toLowerCase().trim())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "USER_NOT_FOUND"));
  }

  public User requireRole(String authorizationHeader, Role requiredRole) {
    String token = extractBearerToken(authorizationHeader);
    final String email;
    final Role role;
    try {
      email = jwtService.extractEmail(token);
      role = jwtService.extractRole(token);
    } catch (JwtException | IllegalArgumentException ex) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "INVALID_AUTH_TOKEN");
    }

    if (role != requiredRole) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, requiredRole.name() + "_ROLE_REQUIRED");
    }

    return users.findByEmail(email.toLowerCase().trim())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "USER_NOT_FOUND"));
  }

  public User requireStandardUser(String authorizationHeader) {
    return requireRole(authorizationHeader, Role.USER);
  }

  private String extractBearerToken(String authorizationHeader) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "AUTHORIZATION_REQUIRED");
    }
    String token = authorizationHeader.substring("Bearer ".length()).trim();
    if (token.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "AUTHORIZATION_REQUIRED");
    }
    return token;
  }
}
