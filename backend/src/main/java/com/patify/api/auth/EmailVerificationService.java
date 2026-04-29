package com.patify.api.auth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;

@Service
public class EmailVerificationService {
  private static final Logger log = LoggerFactory.getLogger(EmailVerificationService.class);
  private static final long RESEND_COOLDOWN_SECONDS = 120;

  private final EmailVerificationTokenRepository tokens;
  private final UserRepository users;
  private final EmailService emailService;
  private final JdbcTemplate jdbcTemplate;
  private final SecureRandom secureRandom = new SecureRandom();
  private final long expiryMinutes;
  private final String baseUrl;

  public EmailVerificationService(
      EmailVerificationTokenRepository tokens,
      UserRepository users,
      EmailService emailService,
      JdbcTemplate jdbcTemplate,
      @Value("${app.emailVerification.expiryMinutes:1440}") long expiryMinutes,
      @Value("${app.emailVerification.base-url:http://localhost:8080}") String baseUrl
  ) {
    this.tokens = tokens;
    this.users = users;
    this.emailService = emailService;
    this.jdbcTemplate = jdbcTemplate;
    this.expiryMinutes = expiryMinutes;
    this.baseUrl = baseUrl;
  }

  @Transactional
  public void createAndSend(User user) {
    String rawToken = generateToken();

    EmailVerificationToken token = new EmailVerificationToken();
    token.user = user;
    token.tokenHash = hash(rawToken);
    token.expiresAt = Instant.now().plusSeconds(expiryMinutes * 60);
    tokens.save(token);
    log.info(
        "[auth][verification-create] token saved tokenId={} userId={} email={} expiresAt={}",
        token.id,
        user.id,
        user.email,
        token.expiresAt
    );

    String encodedToken = URLEncoder.encode(rawToken, StandardCharsets.UTF_8);
    String verificationUrl = baseUrl.replaceAll("/+$", "")
        + "/auth/verify-email?token="
        + encodedToken;
    log.info("[auth][verification-create] sending email userId={} email={} baseUrl={}", user.id, user.email, baseUrl);
    emailService.sendVerificationEmail(user.email, verificationUrl);
  }

  @Transactional
  public void resend(String email) {
    String normalizedEmail = email != null ? email.toLowerCase().trim() : "";
    if (normalizedEmail.isBlank()) {
      log.info("[auth][verification-resend] ignored blank email");
      return;
    }

    User user = users.findByEmail(normalizedEmail).orElse(null);
    if (user == null) {
      log.info("[auth][verification-resend] no account found email={}", normalizedEmail);
      return;
    }

    if (user.emailVerified) {
      log.info("[auth][verification-resend] already verified userId={} email={}", user.id, user.email);
      return;
    }

    Instant now = Instant.now();
    boolean inCooldown = tokens.findTopByUserIdAndUsedAtIsNullOrderByCreatedAtDesc(user.id)
        .map(token -> token.createdAt.plusSeconds(RESEND_COOLDOWN_SECONDS).isAfter(now))
        .orElse(false);
    if (inCooldown) {
      log.info("[auth][verification-resend] throttled userId={} email={}", user.id, user.email);
      return;
    }

    int invalidated = tokens.markUnusedTokensAsUsed(user.id, now);
    log.info("[auth][verification-resend] invalidated old tokens userId={} count={}", user.id, invalidated);
    createAndSend(user);
  }

  @Transactional
  public void verify(String rawToken) {
    if (rawToken == null || rawToken.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_VERIFICATION_TOKEN");
    }

    EmailVerificationToken token = tokens.findByTokenHash(hash(rawToken))
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "INVALID_VERIFICATION_TOKEN"
        ));
    log.info(
        "[auth][verify-email] token found tokenId={} userId={} expiresAt={} usedAt={}",
        token.id,
        token.userId,
        token.expiresAt,
        token.usedAt
    );

    if (token.usedAt != null) {
      log.info("[auth][verify-email] token already used tokenId={} userId={}", token.id, token.userId);
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "VERIFICATION_TOKEN_USED");
    }

    if (token.expiresAt.isBefore(Instant.now())) {
      log.info("[auth][verify-email] token expired tokenId={} userId={} expiresAt={}", token.id, token.userId, token.expiresAt);
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "VERIFICATION_TOKEN_EXPIRED");
    }

    UserVerificationState userBeforeUpdate = readUserVerificationState(token.userId);
    log.info(
        "[auth][verify-email] loaded user for update userId={} email={} emailVerifiedBefore={}",
        userBeforeUpdate.id(),
        userBeforeUpdate.email(),
        userBeforeUpdate.emailVerified()
    );

    int updatedRows = jdbcTemplate.update(
        "UPDATE users SET email_verified = TRUE WHERE id = ?",
        token.userId
    );
    if (updatedRows != 1) {
      log.error("[auth][verify-email] email_verified update failed userId={} updatedRows={}", token.userId, updatedRows);
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "EMAIL_VERIFICATION_UPDATE_FAILED");
    }

    token.usedAt = Instant.now();
    tokens.saveAndFlush(token);

    UserVerificationState verifiedUser = readUserVerificationState(token.userId);
    if (!verifiedUser.emailVerified()) {
      log.error(
          "[auth][verify-email] email_verified still false after update userId={} email={}",
          verifiedUser.id(),
          verifiedUser.email()
      );
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "EMAIL_VERIFICATION_NOT_PERSISTED");
    }

    log.info(
        "[auth][verify-email] persisted user state userId={} email={} emailVerified={} tokenUsedAt={}",
        verifiedUser.id(),
        verifiedUser.email(),
        verifiedUser.emailVerified(),
        token.usedAt
    );
  }

  private UserVerificationState readUserVerificationState(Long userId) {
    return jdbcTemplate.query(
        "SELECT id, email, email_verified FROM users WHERE id = ?",
        (rs) -> {
          if (!rs.next()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "VERIFICATION_USER_NOT_FOUND");
          }
          return new UserVerificationState(
              rs.getLong("id"),
              rs.getString("email"),
              rs.getBoolean("email_verified")
          );
        },
        userId
    );
  }

  private record UserVerificationState(Long id, String email, boolean emailVerified) {}

  private String generateToken() {
    byte[] bytes = new byte[32];
    secureRandom.nextBytes(bytes);
    return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
  }

  private String hash(String token) {
    try {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
      return Base64.getEncoder().encodeToString(hash);
    } catch (NoSuchAlgorithmException e) {
      throw new IllegalStateException("SHA-256 is not available", e);
    }
  }
}
