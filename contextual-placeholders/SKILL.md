---
name: contextual-placeholders
description: Automatically use contextual placeholder images from Unsplash, Picsum, and other services instead of solid color boxes when building UI components with images
---

# Contextual Placeholders

When building UI components that display images, always use real placeholder image services instead of solid color boxes or non-existent local paths.

## Core Rules

1. **Never use solid color boxes as image placeholders** - No `bg-gray-200`, `bg-slate-300`, `bg-blue-500`, or any solid color div where an image should be
2. **Never use fake local paths** - No `/images/placeholder.jpg` or `./assets/hero.png` that don't exist
3. **Never use text-based placeholders** - No `placeholder.com` or `placehold.it`
4. **Always use HTTPS** - All placeholder URLs must use `https://`

## Service Selection

Choose the appropriate service based on what the image represents:

| Use Case | Service | URL Pattern |
|----------|---------|-------------|
| Contextual images (heroes, cards, features) | Unsplash | `https://source.unsplash.com/WxH/?keywords` |
| Random photos (no context needed) | Lorem Picsum | `https://picsum.photos/W/H` |
| Realistic avatars | Pravatar | `https://i.pravatar.cc/SIZE` |
| Realistic avatars (alternative) | RandomUser | `https://randomuser.me/api/portraits/men/N.jpg` or `.../women/N.jpg` |
| Illustrated avatars | DiceBear | `https://api.dicebear.com/7.x/avataaars/svg?seed=NAME` |
| Video placeholders | Pexels | Use Pexels embed or video URL |

## Keyword Selection for Unsplash

Infer keywords from context:

1. **Explicit user context** - If the user says "travel blog hero", use `?travel,landscape`
2. **Component purpose** - A team section implies `?team,office,professional`
3. **Project context** - A restaurant site implies food-related keywords
4. **Combine 2-3 keywords** - `?coffee,cafe,morning` is better than just `?coffee`

## Dimensions Reference

Use appropriate dimensions for the component type:

| Component | Dimensions | Aspect Ratio |
|-----------|------------|--------------|
| Hero/banner | 1920x1080 or 1280x720 | 16:9 |
| Card image | 400x300 or 600x400 | 4:3 |
| Feature image | 800x600 | 4:3 |
| Thumbnail | 200x150 or 150x150 | 4:3 or 1:1 |
| Avatar | 48, 64, 96, or 150 | 1:1 |
| Background | 1920x1080 | 16:9 |

Use source images large enough to scale down gracefully. A 1280x720 image works at any smaller viewport.

## Uniqueness

When multiple similar images appear on the same page, make each unique:

- **Picsum**: Add `?random=N` - `https://picsum.photos/400/300?random=1`, `?random=2`, etc.
- **Unsplash**: Add `&sig=N` - `https://source.unsplash.com/400x300/?nature&sig=1`, `&sig=2`, etc.
- **Pravatar**: Use different numbers - `https://i.pravatar.cc/150?img=1`, `?img=2`, etc.
- **DiceBear**: Use different seeds - `?seed=alice`, `?seed=bob`, or use actual names if available

## Responsive Display

Placeholder dimensions are fixed in the URL, but CSS handles responsive display. Recommend using:

- `object-fit: cover` (or Tailwind's `object-cover`) to fill containers without distortion
- `width: 100%` or `max-width: 100%` for fluid scaling

The placeholder image dimensions don't need to match every breakpoint—CSS handles the presentation.

## What This Skill Does NOT Cover

Leave these unchanged—they are not image placeholders:

- **Skeleton loaders** - Gray animated boxes for loading states are intentional UI
- **Icons** - Use icon libraries (Lucide, Heroicons, etc.), not photos
- **Logos** - Add a comment noting "replace with logo" rather than using a random image
- **Charts/graphs** - Use charting libraries or placeholder components
- **Maps** - Use actual map embeds (Google Maps, Mapbox), not photos of maps
- **Intentional design blocks** - Solid color sections that are part of the design, not placeholders

## Examples

**Hero section for a travel blog:**
```html
<img
  src="https://source.unsplash.com/1920x1080/?travel,adventure,landscape"
  alt="Travel destination"
  class="w-full h-96 object-cover"
/>
```

**Team member cards (4 people):**
```html
<img src="https://i.pravatar.cc/150?img=1" alt="Team member" class="rounded-full" />
<img src="https://i.pravatar.cc/150?img=2" alt="Team member" class="rounded-full" />
<img src="https://i.pravatar.cc/150?img=3" alt="Team member" class="rounded-full" />
<img src="https://i.pravatar.cc/150?img=4" alt="Team member" class="rounded-full" />
```

**Product cards for an e-commerce site:**
```html
<img src="https://source.unsplash.com/400x300/?sneakers,shoes&sig=1" alt="Product" class="object-cover" />
<img src="https://source.unsplash.com/400x300/?sneakers,shoes&sig=2" alt="Product" class="object-cover" />
<img src="https://source.unsplash.com/400x300/?sneakers,shoes&sig=3" alt="Product" class="object-cover" />
```

**Generic card grid (no specific context):**
```html
<img src="https://picsum.photos/400/300?random=1" alt="Card image" />
<img src="https://picsum.photos/400/300?random=2" alt="Card image" />
<img src="https://picsum.photos/400/300?random=3" alt="Card image" />
```

**Illustrated avatar for a chat app:**
```html
<img src="https://api.dicebear.com/7.x/avataaars/svg?seed=johndoe" alt="User avatar" />
```
