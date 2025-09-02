# 📦 FB_FilterDebounce

> **Category**  : Function Block  
> **Version**   : v2.0.0  
> **Author**    : Ridvan Kahraman  
> **Created**   : 2025-09-02  
> **License**   : MIT  

---

## ⚠️ Syntax Highlighting Note

> GitHub does not support native syntax highlighting for `.st` files (Structured Text – IEC 61131-3).  
> To improve readability, Pascal highlighting is applied via a `.gitattributes` override.  

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

| Name          | Type    | Description                                 |
|---------------|---------|---------------------------------------------|
| `q_SigDeb`    | `BOOL`  | The debounced (filtered) digital output.    |
| `q_Fault`     | `BOOL`  | Set if i_DebTime is out of allowed range.   |

---

## 🔄 Behavior

| Condition                                         | Action                                                    |
|---------------------------------------------------|-----------------------------------------------------------|
| Input changes & remains stable for `i_DebTime`.   | Output updates to new value.                              |
| Input bounces back before timer elapses.          | Timer resets, output remains unchanged.                   |
| `i_FiltEn = FALSE`                                | Output forced to FALSE as fail-safe fallback.             |
| `i_DebTime` invalid (<0 or >1s)                   | Clamped internally, q_Fault set.                          |

---

## 🛡️ SIL-2 Considerations

- **Failsafe Default**: When disabled, falls back to raw input (`i_SigRaw`).  
- **Debounce Clamp**: Debounce time is limited to `0 ms ... 1000 ms` for safety.  
- **Stateless Operation**: No retained memory, all transitions are event-driven.  
- **Explicit Edge Control**: Stable transitions required for timer completion.  

---

## 📁 Example Use

```iec
fb_Debounce : FB_FilterDebounce;

fb_Debounce(    i_FiltEn    :=  TRUE,
                i_SigRaw    :=  InputSensor,
                i_DebTime   :=  T#100ms
                q_SigDeb    =>  OutputSignal
                q_Fault     =>  ConfigFault);
```
