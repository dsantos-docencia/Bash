# 🌍 Translations · Traduções

**🌍 Idioma / Language:** [Português](README.md) · **English**

This course was born in **Brazilian Portuguese** and is being translated to reach more people. **Your help is welcome!**

---

## How the translation pattern works

Each content file has the original version (`README.md`, in Portuguese) and, next to it, the translated version with the language suffix: **`README.en.md`** (English), `README.es.md` (Spanish), etc. — following the [BCP-47](https://en.wikipedia.org/wiki/IETF_language_tag) codes.

```
modulos/00-boas-vindas-e-fundamentos/
├── README.md        ← original (pt-BR)
├── README.en.md     ← English
└── README.es.md     ← Spanish (example)
```

Simple rules:
- **Translate the text, not the code.** Variable names, commands, and the examples' output stay as they are (they're tested). Translate comments and narration when it helps.
- **Keep relative links** pointing to the equivalent files (English pages link to the `.en.md` siblings).
- **Keep the authorship and license header.**
- At the top of each file, keep the language selector pointing to the other versions.

> ⚠️ **The exercises' expected outputs are kept in Portuguese on purpose** — the automated grader checks those strings literally, so a learner's script must print exactly them to pass. Translate the instructions around them, not the literal `# -> ...` outputs.

## Progress

| Content | 🇧🇷 pt-BR | 🇬🇧 en | 🇪🇸 es |
|---|:---:|:---:|:---:|
| README (cover) | ✅ | ✅ | — |
| CONTRIBUTING | ✅ | ✅ | — |
| Module READMEs (00–11) | ✅ | ✅ | — |
| Exercise READMEs | ✅ | ✅ | — |
| Project READMEs | ✅ | ✅ | — |
| Reference (cheat-sheet, tables, man) | ✅ | ✅ | — |
| Comments inside the scripts | ✅ | 🚧 help! | — |

✅ done · 🚧 open (grab one and contribute!) · — not started yet

> The pages are all in English; what's still open is translating the **comments inside the scripts** (`.sh`) — and, of course, **corrections and improvements** to the existing translations are always welcome. Spotted a slip? Open an issue or PR.

## Want to translate?

1. Pick a file marked 🚧 (or start a new language).
2. Open an issue saying what you'll translate (avoids duplicate work).
3. Create the `*.<language>.md` file next to the original.
4. Open a Pull Request. You go into [CONTRIBUTORS.md](../CONTRIBUTORS.md) and keep credit for the translation.

Even translating **one module** helps a lot of people. Thank you! 💚

<sub>© 2026 Prof. Daniel Santos and translators · Content CC BY-NC-SA 4.0 (noncommercial use)</sub>
