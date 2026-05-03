package com.patify.api.auth;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
  Optional<User> findByEmail(String email);

  List<User> findAllByEmailVerifiedTrue();

  List<User> findAllByEmailVerifiedTrueAndDistrictIgnoreCase(String district);
}
