package com.patify.api.auth;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;

public interface EmailVerificationTokenRepository
    extends JpaRepository<EmailVerificationToken, Long> {
  Optional<EmailVerificationToken> findByTokenHash(String tokenHash);

  Optional<EmailVerificationToken> findTopByUserIdAndUsedAtIsNullOrderByCreatedAtDesc(Long userId);

  @Modifying
  @Query("UPDATE EmailVerificationToken t SET t.usedAt = :usedAt WHERE t.user.id = :userId AND t.usedAt IS NULL")
  int markUnusedTokensAsUsed(@Param("userId") Long userId, @Param("usedAt") Instant usedAt);
}
