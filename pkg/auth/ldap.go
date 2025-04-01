package auth

import (
	"fmt"

	"github.com/go-ldap/ldap/v3"
)

type LDAPConfig struct {
	URL      string
	BaseDN   string
	BindDN   string
	BindPass string
}

type LDAPClient struct {
	config *LDAPConfig
}

func NewLDAPClient(config *LDAPConfig) *LDAPClient {
	return &LDAPClient{
		config: config,
	}
}

func (c *LDAPClient) Authenticate(username, password string) (bool, error) {
	l, err := ldap.DialURL(c.config.URL)
	if err != nil {
		return false, fmt.Errorf("failed to connect to LDAP server: %v", err)
	}
	defer l.Close()

	// First bind with a read only user
	err = l.Bind(c.config.BindDN, c.config.BindPass)
	if err != nil {
		return false, fmt.Errorf("failed to bind with service account: %v", err)
	}

	// Search for the user
	searchRequest := ldap.NewSearchRequest(
		c.config.BaseDN,
		ldap.ScopeWholeSubtree, ldap.NeverDerefAliases, 0, 0, false,
		fmt.Sprintf("(&(objectClass=person)(uid=%s))", username),
		[]string{"dn"},
		nil,
	)

	sr, err := l.Search(searchRequest)
	if err != nil {
		return false, fmt.Errorf("failed to search user: %v", err)
	}

	if len(sr.Entries) != 1 {
		return false, fmt.Errorf("user not found or too many entries returned")
	}

	userdn := sr.Entries[0].DN

	// Bind as the user to verify their password
	err = l.Bind(userdn, password)
	if err != nil {
		return false, nil
	}

	return true, nil
}
