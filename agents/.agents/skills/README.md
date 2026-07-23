# Agent Skills

Place shared LLM agent skills in this directory. Each skill should have its own directory containing a `SKILL.md` file and any supporting resources:

```text
skills/
└── tailor-resume/
    ├── SKILL.md
    └── resources/
        └── tailor-resume.py
```

The `agents` GNU Stow package maps this directory to `~/.agents/skills` on every supported operating system.
