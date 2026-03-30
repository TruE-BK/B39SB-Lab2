# Part C: Sampling Theorem - Answers

## Question 4 (15%): Explain observations in (b) and (c) using harmonic sampling theory

**Answer:**

### Background: Nyquist Sampling Theorem
For a signal with maximum frequency component $f_c$, the minimum sampling frequency is $f_s = 2f_c$ (Nyquist rate). Equivalently, the maximum sampling interval is $T_{max} = \frac{1}{2f_c}$.

### Our Sine Wave Signal
- 8 cycles in 512 samples
- Samples per cycle: $512/8 = 64$
- To get 2 samples per cycle (Nyquist rate): $T = 32$

### Experimental Results

#### Case 1: T = 16 (Above Nyquist Rate - Oversampling)
- **Samples per cycle**: 4
- **Result**: Excellent reconstruction
- The reconstruction (green line) closely follows the original (red line)
- Sampling points (blue circles) capture the waveform accurately
- **Reason**: With more than 2 samples per cycle, we have sufficient information to reconstruct the continuous signal perfectly

#### Case 2: T = 32 (At Nyquist Rate)
- **Samples per cycle**: 2
- **Result**: Theoretically perfect reconstruction, but practically challenging
- The samples occur at the peaks and troughs of the sine wave
- **Reason**: Exactly at the theoretical limit. The Shannon reconstruction formula assumes infinite sum and ideal conditions. With finite samples and practical implementation, some edge effects may occur.

#### Case 3: T = 48 (Below Nyquist Rate - Undersampling/Aliasing)
- **Samples per cycle**: 1.33
- **Result**: Severe distortion in reconstruction
- **Reason**: **Aliasing occurs**

### Aliasing Explanation

When $f_s < 2f_c$ (or $T > T_{Nyquist}$), the frequency components above $f_s/2$ "fold back" into the lower frequency range:

$$f_{alias} = |f - k \cdot f_s|$$

For our 8-cycle sine wave sampled at T=48 (effectively $f_s = 512/48 \approx 10.67$ cycles):
- Original frequency: 8 cycles
- Sampling creates an alias at approximately: $|8 - 10.67| \approx 2.67$ cycles

The reconstructed signal appears as a lower frequency wave that passes through the same sample points but is not the original signal. This is why the green reconstruction curve shows a different frequency than the original red curve.

### Conclusion
The experiments demonstrate the critical importance of the Nyquist criterion:
- **Oversampling** (T < 32): Safe, accurate reconstruction
- **Nyquist sampling** (T = 32): Theoretical limit, works with ideal conditions
- **Undersampling** (T > 32): Aliasing causes irreversible information loss

---

## Question 5 (15%): Why does square wave reconstruction distort more than sine wave at same sampling rate?

**Answer:**

### Key Difference: Frequency Content

**Sine Wave (8 cycles):**
- Pure single frequency: 8 cycles per 512 samples
- Bandwidth: theoretically a single frequency component
- Maximum frequency: 8 cycles

**Square Wave (4 periods):**
- Fundamental frequency: 4 cycles per 512 samples
- However, square waves contain **infinite odd harmonics**:
$$x_{square}(t) = \frac{4}{\pi}\sum_{k=1,3,5,...}^{\infty} \frac{1}{k}\sin(2\pi k f_0 t)$$

Where $f_0 = 4$ cycles is the fundamental frequency.

### Frequency Spectrum Comparison

| Harmonic | Square Wave Component | Relative Amplitude |
|----------|----------------------|-------------------|
| 1st (fundamental) | 4 cycles | 1.000 |
| 3rd harmonic | 12 cycles | 0.333 |
| 5th harmonic | 20 cycles | 0.200 |
| 7th harmonic | 28 cycles | 0.143 |
| 9th harmonic | 36 cycles | 0.111 |
| ... | ... | ... |

### Why More Distortion Occurs

1. **Higher Frequency Components**: While the square wave's fundamental (4 cycles) is lower than the sine wave's frequency (8 cycles), the square wave contains significant energy at much higher frequencies.

2. **Bandwidth Limitation**: The `shannon()` reconstruction function assumes the signal is band-limited. A true square wave is NOT band-limited—it has infinite frequency content.

3. **Gibbs Phenomenon**: Even with sufficient sampling, the reconstruction of a square wave using band-limited methods shows ringing/overshoot near discontinuities (Gibbs phenomenon).

4. **Aliasing of Harmonics**: At the same sampling rate:
   - For sine wave at T=32: sampling rate = 2× signal frequency ✓
   - For square wave at T=32: sampling rate may be < 2× higher harmonics ✗

### Example Calculation

At T=32 sampling:
- Nyquist frequency: $f_s/2 = 512/(2×32) = 8$ cycles
- Square wave harmonics above 8 cycles: 12, 20, 28, 36, ...
- Harmonics 12, 20, 28 will alias!

This means the reconstruction contains aliased frequency components that distort the waveform shape significantly.

### Conclusion

Even though the square wave has a **lower fundamental frequency** than the sine wave, it **distorts more** because:
1. It is not band-limited (contains infinite harmonics)
2. The higher harmonics exceed the Nyquist frequency and alias
3. The sharp edges of the square wave require very high frequencies to reconstruct accurately
4. The Shannon reconstruction formula, designed for band-limited signals, cannot perfectly reconstruct non-band-limited signals like square waves

This demonstrates that **signal bandwidth**, not just fundamental frequency, determines the required sampling rate.

---

## Summary of Part C Experiments

| Signal | Frequency Content | Sampling Challenge |
|--------|------------------|-------------------|
| Sine wave | Single frequency | Easy to satisfy Nyquist |
| Square wave | Infinite harmonics | Aliasing of high harmonics |
| Blood velocity | Unknown, but band-limited | Choose T based on highest frequency |

**Key Learning**: The Sampling Theorem requires the signal to be **strictly band-limited**. Real-world signals should be low-pass filtered before sampling to prevent aliasing.
