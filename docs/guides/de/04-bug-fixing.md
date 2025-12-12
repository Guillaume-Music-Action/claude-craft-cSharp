# Anleitung zur Fehlerbehebung

Systematischer Ansatz zur Fehlerbehebung mit Claude-Craft.

---

## Workflow zur Fehlerbehebung

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 1. Reproduzieren│ -->│2. Diagnostizieren│ --> │  3. Test    │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              v
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 6. Dokumentieren│ <--│  5. Validieren│ <--│ 4. Beheben  │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Phase 1: Reproduzieren

- Informationen aus dem Fehlerbericht sammeln
- Reproduktionsumgebung erstellen
- Überprüfen, ob der Fehler konsistent ist

---

## Phase 2: Diagnostizieren

```bash
/common:analyze-bug "Benutzer können sich nach Passwort-Reset nicht anmelden"
```

```markdown
@tdd-coach Hilf mir, diesen Authentifizierungsfehler zu diagnostizieren
```

---

## Phase 3: Regressionstest

```php
/**
 * @test
 * @see https://github.com/company/project/issues/123
 *
 * Bug: Benutzer konnten sich nach Reset nicht anmelden
 */
public function test_user_can_login_after_password_reset(): void
{
    $user = $this->createUser('user@example.com', 'old-password');
    $this->passwordResetService->resetPassword($user, 'new-password');

    $result = $this->authService->authenticate('user@example.com', 'new-password');

    $this->assertTrue($result->isSuccess());
}
```

---

## Phase 4: Beheben

```php
// VORHER (fehlerhaft)
public function resetPassword(User $user, string $newPassword): void
{
    $hash = $this->hasher->hash($newPassword);
    $user->setPasswordHash($hash);
    // Bug: persist/flush fehlt!
}

// NACHHER (behoben)
public function resetPassword(User $user, string $newPassword): void
{
    $hash = $this->hasher->hash($newPassword);
    $user->setPasswordHash($hash);
    $this->entityManager->persist($user);  // <-- Korrektur
    $this->entityManager->flush();          // <-- Korrektur
}
```

---

## Phase 5: Validieren

```bash
make test
/symfony:check-compliance
```

```markdown
@symfony-reviewer Überprüfe meine Korrektur für Issue #123
```

---

## Phase 6: Dokumentieren

```bash
git commit -m "fix(auth): Login-Fehler nach Passwort-Reset behoben

Bug: Benutzer konnten sich nach Passwort-Reset nicht anmelden
Ursache: Passwort-Hash wurde nicht in der Datenbank persistiert
Korrektur: persist() und flush() in PasswordResetService hinzugefügt

Closes #123"
```

---

## Hotfix-Verfahren

```bash
# 1. Hotfix-Branch erstellen
git checkout production
git checkout -b hotfix/issue-123

# 2. Korrektur und Test anwenden

# 3. Verifizieren
make test
/symfony:check-compliance

# 4. PR erstellen
gh pr create --base production --title "HOTFIX: Login-Fehler"

# 5. Nach Merge in main mergen
git checkout main
git merge hotfix/issue-123
```

---

## Korrektur-Checkliste

- [ ] Fehler lokal reproduziert
- [ ] Regressionstest geschrieben (schlägt fehl)
- [ ] Code korrigiert
- [ ] Test besteht
- [ ] Keine Regressionen
- [ ] Commit mit Issue-Referenz

---

[&larr; Feature-Entwicklung](03-feature-development.md) | [Werkzeuge-Referenz &rarr;](05-tools-reference.md)
