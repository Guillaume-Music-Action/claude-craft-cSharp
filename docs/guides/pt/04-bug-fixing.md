# Guia de Correção de Bugs

Abordagem sistemática para corrigir bugs com Claude-Craft.

---

## Fluxo de Correção

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 1. Reproduzir│ -->│2. Diagnosticar│ --> │  3. Teste   │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              v
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 6. Documentar│ <--│  5. Validar │ <-- │ 4. Corrigir │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Fase 1: Reproduzir

- Coletar informações do relatório de bug
- Criar ambiente de reprodução
- Verificar que o bug é consistente

---

## Fase 2: Diagnosticar

```bash
/common:analyze-bug "Os usuários não conseguem fazer login após redefinir a senha"
```

```markdown
@tdd-coach Ajude-me a diagnosticar este bug de autenticação
```

---

## Fase 3: Teste de Regressão

```php
/**
 * @test
 * @see https://github.com/company/project/issues/123
 *
 * Bug: Os usuários não conseguiam fazer login após redefinição
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

## Fase 4: Corrigir

```php
// ANTES (com bug)
public function resetPassword(User $user, string $newPassword): void
{
    $hash = $this->hasher->hash($newPassword);
    $user->setPasswordHash($hash);
    // Bug: Falta persist/flush!
}

// DEPOIS (corrigido)
public function resetPassword(User $user, string $newPassword): void
{
    $hash = $this->hasher->hash($newPassword);
    $user->setPasswordHash($hash);
    $this->entityManager->persist($user);  // <-- Correção
    $this->entityManager->flush();          // <-- Correção
}
```

---

## Fase 5: Validar

```bash
make test
/symfony:check-compliance
```

```markdown
@symfony-reviewer Revise minha correção para o issue #123
```

---

## Fase 6: Documentar

```bash
git commit -m "fix(auth): resolver falha de login após redefinição de senha

Bug: Os usuários não conseguiam fazer login após redefinir senha
Causa raiz: O hash não era persistido no banco de dados
Correção: Adicionados persist() e flush() em PasswordResetService

Closes #123"
```

---

## Procedimento Hotfix

```bash
# 1. Criar branch hotfix
git checkout production
git checkout -b hotfix/issue-123

# 2. Aplicar correção e teste

# 3. Verificar
make test
/symfony:check-compliance

# 4. Criar PR
gh pr create --base production --title "HOTFIX: Falha de login"

# 5. Após merge, mergear em main
git checkout main
git merge hotfix/issue-123
```

---

## Checklist de Correção

- [ ] Bug reproduzido localmente
- [ ] Teste de regressão escrito (falha)
- [ ] Código corrigido
- [ ] Teste passa
- [ ] Sem regressões
- [ ] Commit com referência ao issue

---

[&larr; Desenvolvimento de Features](03-feature-development.md) | [Referência de Ferramentas &rarr;](05-tools-reference.md)
