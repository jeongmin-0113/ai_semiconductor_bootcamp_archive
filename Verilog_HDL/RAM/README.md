# RAM — 레지스터와 단일 포트 RAM (순차 / 조합 출력, BRAM vs LUTRAM)

> 📅 2026-08-10 · 보드: Basys3 · Vivado 2020.2 · 시뮬레이션

FIFO를 만들기 전에 메모리의 기본 단위를 직접 작성해 본 실습.
8bit 레지스터(F/F)와 write enable 레지스터, 주소로 접근하는 단일 포트 RAM을 만들고
**읽기 출력을 순차(F/F)로 낼 때와 조합으로 낼 때의 1clk 차이**, Vivado가 메모리를 **LUTRAM / BRAM** 중 무엇으로 합성하는지 확인함.

## 파일 구조

```
RAM/
├── src/
│   ├── register_8.v    # register_8, register_8_we
│   └── ram_ip.v        # ram_id (1K × 8bit, 순차 읽기)
└── tb/tb_ram_ip.v
```

---

## 레지스터

```verilog
// 매 clk마다 d를 저장
always @(posedge clk, posedge reset)
    if (reset) q_reg <= 0;
    else       q_reg <= d;

// we가 1일 때만 저장 (write enable)
always @(posedge clk, posedge reset)
    if (reset)   q_reg <= 0;
    else if (we) q_reg <= d;
```

## RAM

```verilog
reg [7:0] ram [0:1023];          // 8bit × 1024 (주소 10bit)

always @(posedge clk) begin
    if (wr) ram[addr] <= wdata;  // write
    else    rdata <= ram[addr];  // read: 순차 출력 → 1clk 지연
end

// 조합 출력 버전
// assign rdata = ram[addr];      // 주소가 바뀌면 바로 출력
```

- 배열은 `[0:size-1]`로 선언 (주소 0부터 증가)
- SRAM에는 **reset이 없음** — 쓰면 그 주소에 저장될 뿐, 전체를 시간 들여 지울 필요가 없음

### 순차 출력 vs 조합 출력

| | 조합 출력 `assign` | 순차 출력 `always` |
|---|---|---|
| 읽기 지연 | 없음 (주소 바뀌면 즉시) | 1clk |
| 하드웨어 | MUX | MUX + F/F |
| 쓰임 | 바로 값이 필요할 때 (FIFO의 read) | 타이밍을 맞춰 내보내야 할 때 |

### LUTRAM vs BRAM

| 크기 | Vivado 합성 결과 |
|---|---|
| 64 × 8bit (`addr[5:0]`) | **LUTRAM** — LUT 안의 저장소를 메모리로 사용 → 로직에 쓸 LUT가 줄어듦 |
| 1024 × 8bit (`addr[9:0]`) | **BRAM** — FPGA 전용 블록 메모리 (보통 1K 단위로 잡힘) |

- 메모리를 쓰는 모듈은 Utilization 리포트에서 **LUT / BRAM 사용량**을 꼭 확인 (일반 로직은 slack 확인)
- 실제 칩 설계에서는 파운드리가 제공하는 RAM IP를 가져다 씀

## Simulation

```verilog
@(negedge clk); wr = 1; addr = 10; wdata = 8'ha;   // 10, 11, 31, 32번지에 a, b, c, d 쓰기
...
@(negedge clk); wr = 0; addr = 10;                 // 같은 주소를 읽기
```

- **조합 출력**: write 직후에는 아직 값이 없어 반 clk 동안 `xx`, 읽기 모드에서는 주소가 바뀌는 즉시 a → b → c → d
- **순차 출력**: write 중에는 출력 없음, 읽기는 주소를 준 **다음 posedge**에 출력
- 입력은 `@(negedge clk)`에서 바꿔 DUT가 posedge에 안정된 값을 샘플하도록 함

---

## 배운 내용

### 메모리 종류

| | Register (F/F) | SRAM | DRAM |
|---|---|---|---|
| 셀 | F/F (D latch 2개, 게이트 10개 수준) → 큼 | 인버터 2개 래치 (6T) | 커패시터 + 트랜지스터 1개 |
| 속도 | CPU와 동일 (edge 동작) | ~2GHz | 1GHz 이하 (멀티 채널로 대역폭 확보) |
| 용량 | 가장 작음 | 중간 | 가장 큼 |
| 특징 | CPU 내부 | 캐시, SoC 내부 메모리 | **refresh 필요** (커패시터 누설) → 속도 한계 |

### ROM

- 전하가 빠지지 않게 두꺼운 절연 배리어를 쌓음 → 그래서 다시 쓰기도 어려움
- EPROM(자외선으로 지움) → EEPROM(전기로 지움) → Flash
- Mask ROM(공장에서 고정), OTP(1번만), MTP(OTP 여러 개), FRAM(이상적이지만 비쌈)

### SRAM 칩 읽는 법 (예: 62256)

- 주소 15bit × 데이터 8bit → 2¹⁵ × 8 = 256Kbit = 32KB
- I/O 핀을 read / write가 공유하는 **싱글 포트** → `WE`, `OE`(active-low)로 한 번에 하나만
- 듀얼 포트: read / write 포트가 분리 → 같은 clk이면 **동기식 FIFO**, 다른 clk이면 **비동기식 FIFO**(CDC)
