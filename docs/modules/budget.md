# budget

## What it is

A monthly AWS Budget filtered to `Project = tinyuka-2025-capstone`.

- Prod limit: **$20**
- Dev limit: **$15**
- Email: `lemikanemmanuel@gmail.com`
- Alerts: 80% forecasted, 100% actual

## Why

| Decision | Thought process | Advantage |
| --- | --- | --- |
| Tag-scoped budget | Only this project’s spend | Noise from other account resources stays out |
| Email in tfvars (not a CI secret override) | Empty CI secrets used to blank the address | Alerts always have a real inbox |
