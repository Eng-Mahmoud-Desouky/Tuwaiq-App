---
name: $CRATCH
colors:
  surface: '#f2fbfa'
  surface-dim: '#d3dcdb'
  surface-bright: '#f2fbfa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#ecf5f4'
  surface-container: '#e7f0ef'
  surface-container-high: '#e1eae9'
  surface-container-highest: '#dbe4e3'
  on-surface: '#151d1d'
  on-surface-variant: '#3a4a49'
  inverse-surface: '#293232'
  inverse-on-surface: '#eaf3f2'
  outline: '#6a7a7a'
  outline-variant: '#b9cac9'
  surface-tint: '#006a6a'
  primary: '#006a6a'
  on-primary: '#ffffff'
  primary-container: '#00ffff'
  on-primary-container: '#007272'
  inverse-primary: '#00dddd'
  secondary: '#5d5e62'
  on-secondary: '#ffffff'
  secondary-container: '#dfdfe3'
  on-secondary-container: '#616266'
  tertiary: '#6b5f00'
  on-tertiary: '#ffffff'
  tertiary-container: '#ffe745'
  on-tertiary-container: '#746700'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#00fbfb'
  primary-fixed-dim: '#00dddd'
  on-primary-fixed: '#002020'
  on-primary-fixed-variant: '#004f4f'
  secondary-fixed: '#e2e2e6'
  secondary-fixed-dim: '#c6c6ca'
  on-secondary-fixed: '#1a1c1f'
  on-secondary-fixed-variant: '#45474a'
  tertiary-fixed: '#fce442'
  tertiary-fixed-dim: '#dec723'
  on-tertiary-fixed: '#201c00'
  on-tertiary-fixed-variant: '#504700'
  background: '#f2fbfa'
  on-background: '#151d1d'
  surface-variant: '#dbe4e3'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
The design system embodies a **Modern Clean Tech & Social** aesthetic. It moves away from cold industrialism toward an approachable, friendly, and organic atmosphere. The brand personality is high-energy yet professional, combining the precision of fintech with the fluidity of social platforms. 

The visual language emphasizes clarity through generous whitespace, vibrant electric accents, and soft geometric forms. It is designed to evoke a sense of innovation, speed (represented by the bolt imagery), and effortless usability.

## Colors
The palette is rooted in a crisp, high-contrast light mode.
- **Primary (Electric Blue):** Reserved exclusively for Call-to-Actions (CTAs), active states, and critical interaction points to ensure maximum visibility and energy.
- **Neutral / Text (Dark Slate):** Used for typography and iconography to provide a grounded, sophisticated contrast against the light surfaces.
- **Background & Surface:** A layered approach using a very soft gray for the canvas and pure white for elevated containers, creating a clear distinction between the environment and actionable content.

## Typography
The typography strategy pairs **Plus Jakarta Sans** for headings and labels with **Inter** for body copy. 

Plus Jakarta Sans provides a friendly, optimistic, and modern tech feel that mirrors the curvature of the UI components. Inter is utilized for long-form text and data to maintain high legibility and a neutral, functional tone. Headlines use tight letter-spacing and heavy weights to command attention, while labels are often uppercase or semi-bold to assist in quick information scanning.

## Layout & Spacing
This design system employs a **Fluid Grid** model with a base-8 rhythmic scale. 

- **Desktop:** 12-column grid with 24px gutters and 48px side margins.
- **Tablet:** 8-column grid with 24px gutters and 32px side margins.
- **Mobile:** 4-column grid with 16px gutters and 16px side margins.

Content is organized into "White Space First" clusters, using large 40px or 64px gaps to separate major sections, ensuring the interface feels breathable and organic rather than cramped.

## Elevation & Depth
The system utilizes **Ambient Shadows** to create a sense of height and hierarchy. Shadows are characterized by high diffusion and low opacity, avoiding any harsh lines or metallic effects.

- **Level 1 (Low):** `0px 4px 12px rgba(0, 0, 0, 0.03)` - Used for subtle cards and hover states.
- **Level 2 (Medium):** `0px 8px 24px rgba(0, 0, 0, 0.06)` - Used for primary UI cards and dropdowns.
- **Level 3 (High):** `0px 16px 48px rgba(0, 0, 0, 0.10)` - Used for modals and floating action buttons.

Surfaces are pure white, sitting atop the soft gray background. No borders are required when shadows are present, maintaining a clean "borderless" look.

## Shapes
Geometry is defined by **Smooth Roundedness**. All interactive and structural elements feature a radius between 12px and 16px. 

This approach eliminates sharp edges, reinforcing the "approachable and organic" brand tone. Avatars should be fully circular (pill-shaped), while large containers and cards should adhere to the 16px standard to maintain a consistent visual rhythm.

## Components
- **Buttons:** Primary buttons use the Electric Blue background with Dark Slate or White text (depending on accessibility) and a 12px corner radius. Secondary buttons should be transparent with a subtle 1px slate border or a soft gray fill.
- **Cards:** Pure white backgrounds with Level 2 ambient shadows and 16px corner radius. No visible borders.
- **Input Fields:** Soft gray background (#F1F3F5) with no border in resting state; transitions to a subtle Electric Blue glow on focus.
- **Chips:** Small, pill-shaped indicators with semi-transparent Electric Blue backgrounds (10% opacity) and saturated blue text for "active" states.
- **Lists:** Clean rows separated by whitespace or extremely faint horizontal lines (#EDF2F7).
- **Social Elements:** Profile cards and feed items use the 16px card standard, with plenty of internal padding (24px) to highlight user-generated content.