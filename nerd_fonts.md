# Nerd Fonts

## Definitive Developer Font Guide: Rankings & Configuration (2026)

This document ranks the **Top 14 Developer Fonts** based on community consensus (Reddit, Hacker News, surveys) regarding utility, ergonomics, and long-term eye comfort.

---

## 🚀 Quick Setup: The Golden Rules for iTerm2

When choosing your font in **iTerm2** (`Cmd` + `,` > **Profiles** > **Text**), always apply these rules to prevent layout bugs:

1. **Choose the Base Variant (No Suffix):** Always select `[FontName] Nerd Font`.
2. **Avoid the "Mono" Suffix:** Do **not** select `[FontName] Nerd Font Mono`. In iTerm2, the regular version keeps text monospaced while allowing icons to scale beautifully. The "Mono" suffix forces icons to be tiny and unreadable.
3. **Avoid "NL" Suffixes:** "NL" stands for *No Ligatures*. Only choose an NL font if you explicitly dislike symbols like `!=` merging into `≠`.

---

## 🏆 Updated Official Rankings

### 🥇 Tier 1: The Gold Standards (Install & Forget)

*The most engineered, popular, and ergonomic fonts available today.*

- **1. JetBrains Mono (`JetBrainsMono Nerd Font`)**
  - **Best For:** Everyone.
  - **Why:** The undisputed champion. Its tall x-height makes it the most readable font for 8+ hour coding sessions.
- **2. Monaspace (`MonaspiceNe Nerd Font`)**
  - **Best For:** Innovators & GitHub Copilot users.
  - **Why:** GitHub's new "superfamily" (Neon, Argon, Xenon). It features "texture healing," which subtly adjusts pixel spacing to make code look denser and more uniform than any other font.
- **3. Cascadia Code (`CaskaydiaCove Nerd Font`)**
  - **Best For:** Windows-style aesthetics & cursive lovers.
  - **Why:** Microsoft's default terminal font. It is heavier/bolder than JetBrains, making it incredibly legible on high-res monitors. It supports beautiful cursive italics.
- **4. Fira Code (`FiraCode Nerd Font`)**
  - **Best For:** Ligature lovers.
  - **Why:** The classic choice for merging symbols (`!=`, `=>`) into clean glyphs.

### 🥈 Tier 2: The Power-User & Clarity Picks

*Focus on specific constraints: screen space or low-vision accessibility.*

- **5. Iosevka (`Iosevka Nerd Font`)**
  - **Best For:** Split-screen layouts (tmux/vim).
  - **Why:** The narrowest legible font. Fits 20% more code on screen.
- **6. Intel One Mono (`IntoneMono Nerd Font`)**
  - **Best For:** Eye fatigue reduction.
  - **Why:** Designed by Intel specifically for low-vision developers. It maximizes clarity and character distinction above all else.
- **7. Hack (`Hack Nerd Font`)**
  - **Best For:** Pure terminal usage.
  - **Why:** No gimmicks. Crisp, sharp, and distraction-free.

### 🥉 Tier 3: The Stylized & Niche

*Excellent fonts that have a strong "flavor" you either love or hate.*

- **8. Victor Mono (`VictorMono Nerd Font`)**
  - **The Vibe:** Semi-connected cursive.
  - **Why:** Famous for its dramatic cursive italics for keywords (like *function*, *class*). You will either think it's the most beautiful thing ever or unreadable.
- **9. Meslo LG (`MesloLGS Nerd Font`)**
  - **The Vibe:** The Apple Terminal classic.
  - **Why:** Still the king for *Oh My Zsh* themes, but looks a bit dated for code editing compared to Monaspace/JetBrains.
- **10. Source Code Pro (`SauceCodePro Nerd Font`)**
  - **The Vibe:** Adobe professional.
  - **Why:** Clean and reliable, but feels "wide" compared to modern trends.

---

## 🛠️ Recommended Setup Matrix

For the absolute best setup according to 2026 developer standards, use this hybrid approach:

### iTerm2 (Terminal)

`MesloLGS Nerd Font`

Perfect alignment for CLI status bars & icons.

### VS Code / Neovim

`JetBrainsMono Nerd Font`

Taller letters for maximum reading comfort.

### Comments / Italics

`VictorMono Nerd Font`

(Optional) Use as a secondary font for italics if your IDE supports it.

---

## 💾 Homebrew Installation Reference

If you ever need to re-install or sync these fonts on another Mac, use these exact commands. Homebrew automatically indexes the fonts repository, so you no longer need to manually tap `homebrew/cask-fonts`.

```bash
# Tier 1: The Modern Titans (Must Haves)
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-fira-code-nerd-font
brew install --cask font-monaspice-nerd-font
brew install --cask font-caskaydia-cove-nerd-font

# Tier 2: High-Utility & Clarity Focused
brew install --cask font-iosevka-nerd-font
brew install --cask font-hack-nerd-font
brew install --cask font-intone-mono-nerd-font

# Tier 3: The Reliable Classics & Stylized Picks
brew install --cask font-meslo-lg-nerd-font
brew install --cask font-sauce-code-pro-nerd-font
brew install --cask font-victor-mono-nerd-font

# Tier 4: The Niche & Aesthetic Picks
brew install --cask font-inconsolata-nerd-font
brew install --cask font-0xproto-nerd-font
brew install --cask font-ubuntu-mono-nerd-font
brew install --cask font-anonymice-nerd-font
```
