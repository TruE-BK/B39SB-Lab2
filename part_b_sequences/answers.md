# Part B: Answers to Questions

## Question 1 (5%): Explain why `x1a = (n == m)` works for constructing unit sample sequence

**Answer:**

The expression `(n == m)` performs an **element-wise equality comparison** between the array `n` and the scalar `m`.

- When `n(k) == m`, the comparison returns `1` (TRUE)
- When `n(k) ~= m`, the comparison returns `0` (FALSE)

For a unit sample sequence δ(n-m), we need:
- Value 1 at position n = m
- Value 0 everywhere else

This is exactly what the logical comparison produces. For example, with `n = [-10:39]` and `m = 0`:
- At n = 0: `(0 == 0)` → `1`
- At all other n: `(n == 0)` → `0`

In MATLAB, logical operations on arrays return arrays of 0s and 1s, which directly correspond to the desired unit sample sequence values.

---

## Question 2 (5%): Explain why `x2a = sign(1 + sign(n))` is equivalent to unit step sequence

**Answer:**

Let's analyze this step by step:

**Step 1: Inner `sign(n)`**
- When n < 0: `sign(n)` = -1
- When n = 0: `sign(n)` = 0  
- When n > 0: `sign(n)` = 1

**Step 2: `1 + sign(n)`**
- When n < 0: `1 + (-1)` = 0
- When n = 0: `1 + 0` = 1
- When n > 0: `1 + 1` = 2

**Step 3: Outer `sign(1 + sign(n))`**
- When n < 0: `sign(0)` = 0
- When n = 0: `sign(1)` = 1
- When n > 0: `sign(2)` = 1

**Result:**
| n | sign(n) | 1+sign(n) | sign(1+sign(n)) | u(n) |
|---|---------|-----------|-----------------|------|
| n < 0 | -1 | 0 | 0 | 0 |
| n = 0 | 0 | 1 | 1 | 1 |
| n > 0 | 1 | 2 | 1 | 1 |

The final output matches the unit step sequence u(n) exactly.

---

## Question 3 (5%): What is the appropriate sequence p for part 5(b)?

**Answer:**

For x_5b, we need a sequence that is:
- 1 when 0 ≤ n ≤ 10
- 0 otherwise

This is exactly the rectangular pulse P_10(n), which can be constructed as:

```matlab
p = ((n >= 0) & (n <= 10));
```

Or equivalently using unit steps:
```matlab
p = u(n) - u(n-11);
```

**Verification:**
- For n = 0 to 10: `(n >= 0)` = 1 AND `(n <= 10)` = 1 → p = 1
- For n < 0: `(n >= 0)` = 0 → p = 0
- For n > 10: `(n <= 10)` = 0 → p = 0

Therefore, the appropriate sequence is **p = P_10(n)**, a rectangular pulse from n=0 to n=10.

---

## Summary of Sequences Generated

| Sequence | Description | Formula |
|----------|-------------|---------|
| x1a | Unit impulse at n=0 | δ(n) = (n == 0) |
| x1b | Unit impulse at n=3 | δ(n-3) = (n == 3) |
| x1c | Unit impulse at n=-4 | δ(n+4) = (n == -4) |
| x2a | Unit step at n=0 | u(n) = (n >= 0) |
| x2b | Unit step at n=2 | u(n-2) = (n >= 2) |
| x3a | Rectangular pulse (0 to 10) | P_10(n) = ((n>=0) & (n<=10)) |
| x3b | Rectangular pulse (-5 to 5) | P_10(n+5) = ((n>=-5) & (n<=5)) |
| x3c | Reversed/shifted pulse (-7 to 3) | P_10(3-n) = ((-7<=n) & (n<=3)) |
| x4 | Square wave (period=8) | S_8(n) |
| x5a | Sawtooth wave (period=8) | n/8 mod 1 |
| x5b | Windowed sawtooth | x5a .* P_10(n+10) |
