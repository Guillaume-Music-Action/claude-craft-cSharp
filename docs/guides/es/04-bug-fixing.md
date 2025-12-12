# Guía de Corrección de Bugs

Enfoque sistemático para corregir bugs con Claude-Craft.

---

## Flujo de Corrección

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 1. Reproducir│ --> │2. Diagnosticar│ --> │  3. Test    │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              v
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 6. Documentar│ <-- │  5. Validar │ <-- │ 4. Corregir │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Fase 1: Reproducir

- Recopilar información del reporte de bug
- Crear entorno de reproducción
- Verificar que el bug es consistente

---

## Fase 2: Diagnosticar

```bash
/common:analyze-bug "Los usuarios no pueden iniciar sesión después de restablecer contraseña"
```

```markdown
@tdd-coach Ayúdame a diagnosticar este bug de autenticación
```

---

## Fase 3: Test de Regresión

```php
/**
 * @test
 * @see https://github.com/company/project/issues/123
 *
 * Bug: Los usuarios no podían iniciar sesión después de restablecer
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

## Fase 4: Corregir

```php
// ANTES (con bug)
public function resetPassword(User $user, string $newPassword): void
{
    $hash = $this->hasher->hash($newPassword);
    $user->setPasswordHash($hash);
    // Bug: ¡Falta persist/flush!
}

// DESPUÉS (corregido)
public function resetPassword(User $user, string $newPassword): void
{
    $hash = $this->hasher->hash($newPassword);
    $user->setPasswordHash($hash);
    $this->entityManager->persist($user);  // <-- Corrección
    $this->entityManager->flush();          // <-- Corrección
}
```

---

## Fase 5: Validar

```bash
make test
/symfony:check-compliance
```

```markdown
@symfony-reviewer Revisa mi corrección para el issue #123
```

---

## Fase 6: Documentar

```bash
git commit -m "fix(auth): resolver fallo de inicio de sesión después de restablecimiento

Bug: Los usuarios no podían iniciar sesión después de restablecer
Causa raíz: El hash no se persistía en la base de datos
Corrección: Añadidos persist() y flush() en PasswordResetService

Closes #123"
```

---

## Procedimiento Hotfix

```bash
# 1. Crear rama hotfix
git checkout production
git checkout -b hotfix/issue-123

# 2. Aplicar corrección y test

# 3. Verificar
make test
/symfony:check-compliance

# 4. Crear PR
gh pr create --base production --title "HOTFIX: Fallo de inicio de sesión"

# 5. Después de merge, mergear a main
git checkout main
git merge hotfix/issue-123
```

---

## Checklist de Corrección

- [ ] Bug reproducido localmente
- [ ] Test de regresión escrito (falla)
- [ ] Código corregido
- [ ] Test pasa
- [ ] Sin regresiones
- [ ] Commit con referencia a issue

---

[&larr; Desarrollo de Funcionalidades](03-feature-development.md) | [Referencia de Herramientas &rarr;](05-tools-reference.md)
