# 📦 FB_FilterDebounce

> **Category**  : Function Block  
> **Version**   : v1.0.0  
> **Author**    : Ridvan Kahraman  
> **Created**   : 2025-09-02  
> **License**   : MIT  

---

## ⚠️ Syntax Highlighting Note

> ⚠️ GitHub does not support native syntax highlighting for `.st` files (Structured Text – IEC 61131-3).  
> ⚠️ To improve readability, Pascal highlighting is applied via a `.gitattributes` override.  

---

## 🧠 Purpose

`FB_FilterDebounce` is designed to filter out short-term fluctuations (spikes/bounces) in digital input signals using timer-based debounce logic.  

It ensures that the output only reflects a change in input after the signal remains stable for a configured time window.  

---

## ⚙️ Interface

### 🔹 Inputs

| Name          | Type   | Description                                                               |
|---------------|--------|---------------------------------------------------------------------------|
| `i_FiltEn`    | `BOOL` | Enables the debounce logic. When `FALSE`, output follows input directly.  |
| `i_SigRaw`    | `BOOL` | The raw digital input signal to debounce.                                 |
| `i_DebTime`   | `TIME` | Required stability time for signal change to be accepted.                 |

### 🔹 Outputs

| Name          | Type    | Description                               |
|---------------|---------|-------------------------------------------|
| `q_SigDeb`    | `BOOL`  | The debounced (filtered) digital output.  |

---

## 🔄 Behavior

| Condition                                         | Action                                                    |
|---------------------------------------------------|-----------------------------------------------------------|
| Input changes & remains stable for `i_DebTime`    | Output updates to new value.                              |
| Input bounces back before timer elapses           | Timer resets, output remains unchanged.                   |
| `i_FiltEn = FALSE`                                | Output directly follows `i_SigRaw`, debounce is bypassed. |

---

## 🛡️ SIL-2 Considerations

- **Failsafe Default**: When disabled, falls back to raw input (`i_SigRaw`).  
- **Deterministic Timing**: Uses internal TON timer with explicit enable and reset.  
- **Minimal Side-Effects**: No retained or shared state, purely functional behavior.  

---

## 📁 Example Use

```iec
fb_Debounce : FB_FilterDebounce;

fb_Debounce(    i_FiltEn    :=  TRUE,
                i_SigRaw    :=  InputSensor,
                i_DebTime   :=  T#100ms
                q_SigDeb    =>  OutputSignal);
```
