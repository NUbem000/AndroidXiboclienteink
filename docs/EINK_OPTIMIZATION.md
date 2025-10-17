# E-ink Display Optimization Guide

## Understanding E-ink Technology

E-ink displays are fundamentally different from LCD/OLED screens:
- **Refresh Rate**: ~85Hz max (vs 60fps+ on LCD)
- **Update Types**: Full refresh (slower, clear) vs Partial refresh (faster, ghosting)
- **Ghosting**: Previous content remains visible as "ghost" images
- **Color**: Typically grayscale (16 levels) or black & white only
- **Power**: Only consumes power during updates

## Optimization Strategies

### 1. Eliminate Animations

```kotlin
// GOOD: Instant transition
view.visibility = View.VISIBLE

// BAD: Animated transition
view.animate().alpha(1f).setDuration(300).start()
```

Disable all system animations:
```xml
<style name="Theme.XiboEink">
    <item name="android:windowAnimationStyle">@null</item>
    <item name="android:windowContentTransitions">false</item>
</style>
```

### 2. Refresh Management

**Full Refresh** (every 10 updates):
- Clears ghosting completely
- Takes longer (~800ms)
- Use for: Major content changes

**Partial Refresh**:
- Fast updates (~200ms)
- May leave ghosting
- Use for: Minor updates, text changes

```kotlin
if (updateCount % 10 == 0) {
    einkManager.fullRefresh()
} else {
    einkManager.partialRefresh()
}
```

### 3. Image Optimization

```kotlin
fun optimizeForEink(bitmap: Bitmap): Bitmap {
    // Convert to grayscale
    val colorMatrix = ColorMatrix().apply {
        setSaturation(0f)
    }

    // Increase contrast
    val contrast = 1.3f
    val offset = (1 - contrast) / 2 * 255

    // Apply dithering
    paint.isDither = true

    return optimizedBitmap
}
```

### 4. Layout Best Practices

```xml
<!-- GOOD: Simple, static layout -->
<LinearLayout>
    <TextView android:text="Static Text" />
    <ImageView android:src="@drawable/static_image" />
</LinearLayout>

<!-- BAD: Complex, animated layout -->
<MotionLayout>
    <LottieAnimationView />
</MotionLayout>
```

### 5. Bitmap Formats

- **Preferred**: PNG (lossless)
- **Acceptable**: JPEG (high quality)
- **Avoid**: Animated GIFs, WebP animations

### 6. Text Rendering

```kotlin
// Use high contrast colors
textView.setTextColor(Color.BLACK)
textView.setBackgroundColor(Color.WHITE)

// Disable text shadows and effects
textView.setShadowLayer(0f, 0f, 0f, Color.TRANSPARENT)

// Use clear, readable fonts
textView.typeface = Typeface.MONOSPACE
```

## Device-Specific Tuning

### Allwinner SoCs

Access e-ink controller via:
```cpp
#define EINK_DEVICE "/dev/eink-panel"
```

Common ioctl commands (device-specific):
- `EINK_FULL_REFRESH`: Full screen refresh
- `EINK_PARTIAL_REFRESH`: Partial update
- `EINK_SET_MODE`: Change update mode

### Refresh Modes

| Mode | Speed | Quality | Use Case |
|------|-------|---------|----------|
| DU (Direct Update) | Fastest | Low | Text input |
| GC16 (Grayscale 16) | Medium | High | Images |
| A2 (Animation) | Fast | Medium | Scrolling |
| GL16 | Medium | High | General content |

## Performance Tips

1. **Pre-render Content**
   - Generate bitmaps in background
   - Cache rendered content
   - Avoid real-time rendering

2. **Batch Updates**
   - Group multiple changes
   - Single refresh after all updates
   - Reduce total refresh count

3. **Memory Management**
   - Recycle bitmaps immediately
   - Use scaled-down previews
   - Clear cache regularly

4. **Power Optimization**
   - Longer delays between updates
   - Sleep mode during inactivity
   - Wake-on-schedule

## Testing Checklist

- [ ] No visible animations
- [ ] No ghosting after 10 updates
- [ ] Text is crisp and readable
- [ ] Images display without artifacts
- [ ] Screen updates in <1 second
- [ ] No memory leaks during updates
- [ ] Battery usage is minimal

## Common Issues

### Problem: Ghosting persists
**Solution**: Increase full refresh frequency

### Problem: Updates are slow
**Solution**: Use partial refresh for minor changes

### Problem: Images look washed out
**Solution**: Increase contrast, apply sharpening filter

### Problem: Text is blurry
**Solution**: Use integer scaling, disable anti-aliasing

## References

- [E-ink Technology Overview](https://www.eink.com/)
- [Android View Optimization](https://developer.android.com/topic/performance/rendering)
- [Bitmap Handling Best Practices](https://developer.android.com/topic/performance/graphics)
