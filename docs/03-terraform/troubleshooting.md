# Terraform Troubleshooting

## Purpose
Capture common Terraform failure modes and how to resolve them safely.

## Common Problems
- provider authentication failure
- syntax error
- invalid resource argument
- dependency order issue
- state lock problem
- drift between code and cloud

## Troubleshooting Workflow
1. Run:
   ```bash
   terraform fmt
   terraform validate
   terraform plan
   ```
2. Read the exact error
3. Check provider credentials
4. Check variable values
5. Check state health
6. Re-run plan before any apply

## Useful Commands
```bash
terraform validate
terraform plan
terraform state list
terraform providers
```

## Validation
- error reproduced and understood
- fix applied in code, not guessed
- plan runs cleanly
- apply succeeds only after plan is correct
