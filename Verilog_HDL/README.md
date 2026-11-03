# Verilog HDL

Basys3 (Artix-7 XC7A35T) · Vivado 2020.2 · Verilog / SystemVerilog · UVM (Synopsys VCS / Verdi)

| 날짜 | 프로젝트 | 내용 |
|---|---|---|
| 07/15 | [gates](gates) | 기본 논리 게이트, Vivado RTL flow (시뮬레이션 → 합성 → 구현 → 비트스트림) |
| 07/16 | [adder](adder) | Half / Full adder → 4bit → 8bit ripple carry adder, 계층적 설계 |
| 07/20~21 | [adder_fnd](adder_fnd) | 8bit FA 결과 7-segment 출력, clock divider, N분주 · duty ratio |
| 07/22 | [practice1](practice1) | D F/F, MUX, blocking vs non-blocking, 시뮬레이션 이벤트 순서 |
| 07/22 | [counter_10000](counter_10000) | tick generator + 0~9999 카운터, datapath 분리 |
| 07/23~24 | [moore_fsm](moore_fsm) | Moore FSM (2상태 → 5상태), full case와 latch |
| 07/23~27 | [counter_updown](counter_updown) | up/down 카운터 + FSM control unit + 버튼 디바운서 · 엣지 검출 |
| 07/27 | [pattern_detection](pattern_detection) | 0101 패턴 검출기 Mealy vs Moore |
| 07/27 | [multi_if_vs_if_else_if](multi_if_vs_if_else_if) | 다중 if / if-else if 우선순위와 합성 구조 |
| 07/28 | [stopwatch](stopwatch) | 시:분:초:1/100초 카운터 체인, parameter 재사용, 8자리 FND |
| 08/05~06 | [UART](UART) | 9600bps UART TX / RX, x16 오버샘플링, loopback |
| 07/29~08/07 | [UART_stopwatch](UART_stopwatch) | 프로젝트 1: 스톱워치 + 시계, PC(UART) ASCII 명령 제어 |
| 08/10 | [RAM](RAM) | 레지스터, 단일 포트 RAM, 순차 / 조합 출력, BRAM vs LUTRAM |
| 08/10~11 | [FIFO](FIFO) | 동기식 FIFO + 랜덤 자가 검증 테스트벤치 |
| 08/11 | [FIFO_UART_loopback](FIFO_UART_loopback) | UART RX → FIFO → FIFO → UART TX, UART 모사 task |
| 08/12 | [SR04_controller](SR04_controller) | HC-SR04 초음파 센서 FSM 컨트롤러, echo synchronizer |
| 08/13~14 | [DHT11_controller](DHT11_controller) | DHT11 1-wire `inout` 컨트롤러, ILA 디버깅 |
| 08/18~19 | [adder_sv](adder_sv) | SystemVerilog 클래스 기반 테스트벤치 (gen / drv / mon / scb / env) |
| 08/19~20 | [register_sv](register_sv) | 순차 회로 SV 검증 타이밍, fork / join |
| 08/24 | [sv_oop](sv_oop) | SV OOP 예제 (상속, virtual, static, package, clocking, 다형성) |
| 08/24 | [adder_UVM](adder_UVM) | Vivado UVM 설정, `uvm_sequence_item` / factory |
| 08/25~09/07 | [FIFO_UVM](FIFO_UVM) | 동기식 FIFO UVM 검증 환경 + functional coverage (발표 2) |
| 09/02~10 | [rv32i_cpu_single_cycle](rv32i_cpu_single_cycle) | RISC-V RV32I 싱글 사이클 CPU |

## 빌드

저장소에는 직접 작성한 소스(`src/` 또는 `rtl/`), 테스트벤치(`tb/`), 제약 파일(`constraints/`)만 올림. Vivado 프로젝트 파일은 제외.

1. Vivado에서 새 프로젝트 생성 (Part: `xc7a35tcpg236-1`) → `src/`, `tb/`, `constraints/` 추가
   - `create_project.tcl`이 있는 폴더는 Vivado Tcl 콘솔에서 `source create_project.tcl`
2. 테스트벤치를 Simulation top으로 지정 후 Run Simulation
3. 보드 실습 프로젝트는 Basys3 master XDC에서 사용 핀만 주석 해제 후 Synthesis → Implementation → Bitstream

UVM 프로젝트(`adder_UVM`, `FIFO_UVM`)와 `rv32i_cpu_single_cycle`은 각 README의 실행 방법 참고 (Vivado `-L uvm` 또는 VCS `-ntb_opts uvm`).
