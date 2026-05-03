package com.patify.api.institution;

import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface InstitutionRepository extends JpaRepository<Institution, Long> {
  @EntityGraph(attributePaths = "location")
  List<Institution> findAllByTypeAndDeletedAtIsNullOrderByNameAsc(String type);

  @EntityGraph(attributePaths = "location")
  List<Institution> findAllByTypeInAndDeletedAtIsNullOrderByNameAsc(List<String> types);

  @EntityGraph(attributePaths = "location")
  Optional<Institution> findByIdAndDeletedAtIsNull(Long id);

  Optional<Institution> findByExternalSourceId(String externalSourceId);

  @Query("""
      select i
      from Institution i
      where i.deletedAt is null
        and i.type = :type
        and lower(trim(i.name)) = lower(trim(:name))
        and lower(trim(coalesce(i.address, ''))) = lower(trim(coalesce(:address, '')))
      """)
  Optional<Institution> findDuplicateCandidate(
      @Param("type") String type,
      @Param("name") String name,
      @Param("address") String address
  );

  @EntityGraph(attributePaths = "location")
  @Query("""
      select i
      from Institution i
      where i.deletedAt is null
        and i.type in :types
      order by i.name asc
      """)
  List<Institution> findVeterinaryInstitutions(
      @Param("types") List<String> types,
      Pageable pageable
  );

  @EntityGraph(attributePaths = "location")
  @Query("""
      select i
      from Institution i
      where i.deletedAt is null
        and i.type in :types
        and (
          lower(i.name) like lower(concat('%', :query, '%'))
          or lower(coalesce(i.address, '')) like lower(concat('%', :query, '%'))
          or lower(coalesce(i.email, '')) like lower(concat('%', :query, '%'))
        )
      order by i.name asc
      """)
  List<Institution> searchVeterinaryInstitutions(
      @Param("types") List<String> types,
      @Param("query") String query,
      Pageable pageable
  );
}
