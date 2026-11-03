# sv_oop — SystemVerilog OOP 예제 8개 (상속 · virtual · static · package · interface · 다형성)

> 📅 2026-08-24 · Vivado 2020.2 · SystemVerilog · 시뮬레이션

UVM에 들어가기 전에 UVM이 기반으로 하는 **SystemVerilog 객체지향 문법**을 예제 단위로 실행해 보며 정리한 프로젝트.
각 파일이 독립된 테스트벤치이고 `$display` 출력으로 동작을 확인함.

## 파일 구조

| 파일 | 주제 |
|---|---|
| `tb_practice_oop_ex1.sv` | `extends`, `super.new()` — 생성자 호출 순서 |
| `tb_practice_oop_ex2.sv` | 메서드 override, `super.print()` 호출 여부 |
| `tb_practice_oop_ex3.sv` | `static` 멤버 vs 객체별 멤버 |
| `tb_practice_oop_ex4.sv` | `package` / `import`, class 안 `enum`, `extern` 함수, `::` 4가지 용법 |
| `tb_practice_oop_ex5.sv` | static 변수 + virtual / non-virtual 메서드 비교 |
| `tb_practice_oop_ex6.sv` | 업캐스팅 시 정적 바인딩 vs 동적 바인딩 |
| `tb_practice_oop_ex7.sv` | `interface`, `modport`, `clocking` block |
| `tb_practice_oop_ex8.sv` | 다형성 — 부모 타입 queue에 자식 객체들 저장 |

---

## 1. 상속과 생성자 (ex1, ex2)

```systemverilog
class base_packet;
    int id;
    function new(int id); this.id = id; endfunction
endclass

class eth_packet extends base_packet;
    bit [47:0] mac_da;
    function new(int id, bit [47:0] da);
        super.new(id);          // 부모 생성자는 new의 맨 처음에
        mac_da = da;
    endfunction
endclass
```

- 실행 순서: 부모 `new` → 자식 `new` → 이후 코드. 자식은 부모의 `id`를 자기 멤버처럼 사용
- override한 메서드에서 `super.print()`를 부르면 부모 동작 + 자식 동작, 안 부르면 자식 동작만

## 2. virtual — 정적 바인딩 vs 동적 바인딩 (ex5, ex6)

```systemverilog
transaction t;  read_txn r;
r = new;
t = r;                    // 업캐스팅: handle은 부모 타입, 객체는 자식

t.hello_nonvirtual();     // → transaction:: 버전 (handle 타입 기준, 컴파일 시 결정)
t.hello_virtual();        // → read_txn:: 버전   (실제 객체 기준, 런타임에 결정)
```

| | non-virtual | virtual |
|---|---|---|
| 바인딩 | **정적** — 컴파일 시 handle 타입으로 결정 | **동적** — 실행 중 실제 객체 타입으로 결정 |
| 업캐스팅 시 | 부모 메서드 실행 | 자식 메서드 실행 |

- 부모 타입 handle 하나로 여러 자식 객체를 다루려면(다형성) 메서드를 반드시 `virtual`로
- ex5: 자식에 없는 non-virtual `info()`는 부모 것이 실행되어 부모의 `static KIND`("BASE")를 출력

## 3. static과 `::` (ex3, ex4)

```systemverilog
class packet;
    static int num_created = 0;   // 모든 객체가 공유 (전역처럼 하나)
    int my_serial;                // 객체마다 따로
    function new(); num_created++; my_serial = num_created; endfunction
endclass

$display(packet::num_created);    // 객체 없이도 접근 가능
```

| `::` 용법 | 예 |
|---|---|
| 패키지 안 아이템 | `my_package::bus_txn` |
| static 멤버 | `bus_txn::count` |
| class 안 타입 (enum 등) | `bus_txn::READ` |
| class 밖에서 `extern` 메서드 정의 | `function string bus_txn::info(); ... endfunction` |

- `enum`의 `.name()`으로 값 대신 이름 문자열(`READ`, `WRITE`) 출력
- `extern` 구현도 `endpackage` **안**에 있어야 함 → 실무에서는 파일을 나눠 `` `include ``로 package 안에 넣음
- `$sformatf`: 포맷한 문자열을 반환

## 4. interface · modport · clocking (ex7)

```systemverilog
interface bus_if (input logic clk);
    logic valid, we;  logic [8:0] addr;  logic [31:0] wdata, rdata;

    clocking cb @(posedge clk);
        default input #1step output #1ns;   // 입력은 엣지 1step 전 값, 출력은 엣지 1ns 뒤
        output valid, addr, wdata, we;
        input  rdata;
    endclocking

    modport DUT(input clk, valid, we, addr, wdata, output rdata);
endinterface

module reg_file (bus_if.DUT b);  ...  endmodule   // 포트 하나로 연결
```

- **interface**: 포트를 하나하나 연결하지 않고 묶음으로 연결
- **modport**: 모듈별로 신호 방향을 지정 → 잘못된 방향으로 구동하면 컴파일 시 잡힘
- **clocking block**: TB가 `@(bif.cb)`에 맞춰 `bif.cb.valid <= 1`처럼 구동 → 클럭 엣지에서 DUT와 TB가 같은 신호를 동시에 건드리는 **race condition 제거**, 출력 지연(`#1ns`)으로 실제 레이아웃 후 지연을 흉내 낼 수도 있음

### Verilog / SystemVerilog 이벤트 영역

| 영역 | 처리 |
|---|---|
| Preponed | 엣지 직전 안정된 값 샘플 (assertion, clocking input `#1step`) |
| Active → Inactive → NBA | **설계(module)** 실행: blocking, NBA 우변 계산 → 좌변 반영 |
| Observed | assertion 평가 |
| Reactive → Re-NBA | **테스트벤치(program)** 실행 |
| Postponed | `$strobe`, `$monitor` |

- SV는 설계와 TB의 실행 시간대를 나눠 race를 구조적으로 막음

## 5. 다형성 (ex8)

```systemverilog
transaction lst[$];                       // 부모 타입 queue
lst.push_back(t0);                        // transaction    cost 1
lst.push_back(r0);                        // read_txn       cost 10
lst.push_back(b0);                        // burst_read_txn cost 10 × len(10)
foreach (lst[i]) begin
    lst[i].drive();
    total += lst[i].cost();               // virtual → 각자 자기 cost
end                                       // total = 111
```

- `foreach`의 루프 변수 `i`는 따로 선언 없이 블록 안에서만 유효
- `[$]`: 크기가 변하는 queue (`push_back`, `pop_front`)

---

## 배운 내용 — UVM과의 연결

| SV 개념 | UVM에서 |
|---|---|
| 상속 + `super.new()` | `class my_driver extends uvm_driver`, `super.new(name, parent)` |
| virtual 메서드 | `build_phase`, `run_phase` 등 phase 메서드 override |
| static + `::` | `seq_item::type_id::create()` (factory) |
| package / import | `import uvm_pkg::*;` |
| 다형성 + 업캐스팅 | factory override로 transaction / component 교체 |
| interface | virtual interface를 `uvm_config_db`로 전달 |
