-- Hack: cyberpunk teal colorscheme inspired by ~/.config/ghostty/themes/hack
-- Built around the ghostty palette with selective warm accents for readability
--
-- Transparency: OFF by default. Set `vim.g.hack_transparent = true` before the
-- colorscheme loads to let the terminal background show through (ghostty:
-- background-opacity). It defaulted to ON while this comment said otherwise,
-- and several groups punched opaque holes through it, so the result was
-- half-transparent -- which reads as broken rather than deliberate.
--
-- Groups live in lua/theme.lua; this file is only the palette.

local c = {
    -- ── Backgrounds ───────────────────────────────────────────────────
    bg          = "#01161b",  -- main editor bg (matches ghostty)
    bg_dark     = "#000a0d",  -- floats, deeper panels
    bg_alt      = "#021e25",  -- slightly raised surfaces
    bg_surface  = "#032932",  -- pmenu, telescope prompts
    bg_highlight= "#022730",  -- cursorline
    bg_selection= "#0a5e66",  -- visual selection (clearly visible against bg)
    bg_search   = "#5dc5ce",  -- search match bg
    bg_grid     = "#0a4548",  -- borders, splits
    bg_indent   = "#08323a",  -- indent guides

    -- ── Foregrounds ───────────────────────────────────────────────────
    fg          = "#b8e8ec",  -- main fg (softened cyan, easier on the eyes)
    fg_bright   = "#66FFFF",  -- ghostty fg, used for emphasis
    fg_muted    = "#7d9b9f",  -- secondary text
    fg_dim      = "#4d6a6e",  -- inactive / metadata
    fg_subtle   = "#2d4549",  -- line numbers, gutters

    -- ── Ghostty teal ladder (palette 1–6 + bright fg) ────────────────
    teal_1      = "#007b82",
    teal_2      = "#028c94",
    teal_3      = "#039ca4",
    teal_4      = "#04acb5",
    teal_5      = "#05bbc5",
    teal_6      = "#06ccd7",
    teal_hi     = "#66FFFF",

    -- ── Selective accents (kept harmonious; used sparingly) ──────────
    amber       = "#e8c87a",  -- strings — warm but desaturated
    amber_dim   = "#a89358",  -- string escapes
    coral       = "#ff7a8c",  -- errors, exceptions
    rose        = "#e88aa6",  -- numbers, constants
    sage        = "#8ad4a6",  -- booleans, special values
    lavender    = "#b8a4e3",  -- types, classes
    lavender_dim= "#8a7fb0",

    -- ── Diff ──────────────────────────────────────────────────────────
    diff_add    = "#013128",
    diff_change = "#012a3a",
    diff_delete = "#2a1014",
    diff_text   = "#02384a",

    -- ── Markdown heading bars (dim tints of each heading fg) ──────────
    h1_bg       = "#04333c",
    h2_bg       = "#032c34",
    h3_bg       = "#03252c",
    h4_bg       = "#1d1a2e",
    h5_bg       = "#2a2418",
    h6_bg       = "#2a1b23",
}

require("theme").apply("hack", c, { transparent = vim.g.hack_transparent == true })
