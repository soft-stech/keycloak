package org.keycloak.models.jpa.entities;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 * @author <a href="mailto:bill@burkecentral.com">Bill Burke</a>
 * @version $Revision: 1 $
 */
@NamedQueries({
        @NamedQuery(name="userHasApplicationRole", query="select m from ApplicationUserRoleMappingEntity m where m.user = :user and m.role = :role and m.application = :application"),
        @NamedQuery(name="userApplicationMappings", query="select m from ApplicationUserRoleMappingEntity m where m.user = :user and m.application = :application")
})
@Entity
public class ApplicationUserRoleMappingEntity extends UserRoleMappingEntity {

    @ManyToOne
    protected ApplicationEntity application;

    public ApplicationEntity getApplication() {
        return application;
    }

    public void setApplication(ApplicationEntity application) {
        this.application = application;
    }
}
