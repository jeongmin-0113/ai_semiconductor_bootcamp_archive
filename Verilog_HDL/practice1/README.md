# practice1 — D flip-flop, MUX, blocking vs non-blocking

> 📅 2026-07-22 · Vivado 2020.2 · 시뮬레이션 전용

순차논리(D F/F)와 조합논리(MUX)를 `always`로 각각 작성해 보고,
**blocking(`=`) / non-blocking(`<=`) 할당의 실행 순서 차이**와 Verilog 시뮬레이터의 이벤트 처리 순서를 테스트벤치로 확인한 연습 프로젝트.

## 파일 구조

```
practice1/
├── src/
│   ├── dff.v           # D flip-flop (순차논리)
│   └── mux.v           # 2:1 MUX (조합논리)
└── tb/tb_practice1.v   # tb_practice1 (swap), tb_delay (딜레이 위치)
```

---

## 코드

```verilog
// D flip-flop: clk 상승엣지에 din을 저장, 다음 clk까지 유지
always @(posedge clk) qout <= din;

// 2:1 MUX: 입력이 바뀌면 바로 출력 (조합논리 → always @(*) + blocking)
always @(*) begin
    if (sel) mux_out = b;
    else     mux_out = a;
end
```

## 실습 1: swap — blocking vs non-blocking

초기값 `a = 0`, `b = 1`에서 clk마다 두 값을 맞바꾸려고 할 때:

| blocking | non-blocking |
|---|---|
| `a = b;`<br>`b = a;` | `a <= b;`<br>`b <= a;` |
| `a`가 먼저 1로 바뀐 뒤 `b`가 **바뀐 `a`** 를 읽음 → `a = b = 1` | 두 우변을 **begin 시점 값**으로 먼저 계산 → 동시에 대입 → 매 clk마다 swap |

## 실습 2: 딜레이 위치와 실행 시점

```verilog
initial begin                   // blocking: 앞 문장이 끝나야 다음 문장 시작
    blk_a = #15 1'b1;           // 15ns
    blk_b = #5  1'b0;           // 20ns (15 + 5)
    blk_c = #10 1'b1;           // 30ns (20 + 10)
end

initial begin                   // non-blocking: 모두 0ns에 예약, 각자 딜레이 후 반영
    nblk_a <= #15 1'b1;         // 15ns
    nblk_b <= #5  1'b0;         // 5ns
    nblk_c <= #10 1'b1;         // 10ns
end
```

---

## 배운 내용

### 연속 할당 vs 절차적 할당

| | 연속 할당 `assign` | 절차적 할당 `=`, `<=` |
|---|---|---|
| 위치 | 모듈 본문 | `initial`, `always` 블록 안 |
| 좌변 | net (`wire`) | variable (`reg`, `integer`, ...) |
| 동작 | 우변이 바뀔 때마다 계속 드라이빙 (선이 연결된 상태) | 순서대로 실행되어 값을 갱신하고 끝 |

### blocking `=` vs non-blocking `<=`

| | blocking `=` | non-blocking `<=` |
|---|---|---|
| 실행 | C 대입문처럼 **쓴 순서대로, 즉시 반영** | 우변을 먼저 다 계산해 두고 **블록 끝에서 한꺼번에 반영** |
| 용도 | 조합논리 | 순차논리 (F/F) |

### Verilog 시뮬레이션 이벤트 순서 (같은 time slot 안에서)

F/F가 clk 엣지에서 값을 내보내는 과정을 모사하는 규칙.

1. **Active**: `assign` 평가, blocking 실행·즉시 반영, **non-blocking 우변(RHS) 계산**, `$display`
2. **Inactive**: `#0` 딜레이 이벤트
3. **NBA**: Active에서 계산해 둔 non-blocking **좌변(LHS)에 일괄 대입**
4. **Postponed**: `$strobe`, `$monitor` — 모든 변화가 끝난 상태 관찰

### F/F는 언제 값을 내보내나

- schematic상 카운터는 F/F(`RTL_REG_ASYNC`) + 덧셈기(`RTL_ADD`, 조합논리)로 구성
- clk 엣지 전에는 Q가 이전 값을 내보내고 D에는 다음 값(`+1`)이 대기
- 엣지 순간에 바로 바뀌면 무한루프가 되므로, 실제 하드웨어는 엣지 이후 **약간의 지연 뒤** Q가 갱신됨 → 시뮬레이터는 이를 NBA region으로 흉내냄
