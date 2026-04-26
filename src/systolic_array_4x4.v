`timescale 1ns / 1ps

module systolic_array_4x4 #(
    parameter DATA_WIDTH = 16,
    parameter ACC_WIDTH = 34 // PE랑 비트수 34로 꼭 맞춰야 함 안 그러면 Bit-width mismatch 에러
)(
    input clk, rst_n, drain,
    input signed [DATA_WIDTH-1:0] a_in_0, a_in_1, a_in_2, a_in_3,
    input signed [DATA_WIDTH-1:0] b_in_0, b_in_1, b_in_2, b_in_3,
    input signed [ACC_WIDTH-1:0]  p_in_0, p_in_1, p_in_2, p_in_3,
    output signed [ACC_WIDTH-1:0] p_out_0, p_out_1, p_out_2, p_out_3
);
    wire signed [DATA_WIDTH-1:0] a_w [0:3][0:4];
    wire signed [DATA_WIDTH-1:0] b_w [0:4][0:3];
    wire signed [ACC_WIDTH-1:0]  p_w [0:4][0:3];

    // 다차원 배열을 concat({a, b} = {c, d})으로 한 번에 할당하려고 했더니 오류 발생
    // 1D 신호 기준이라서 synthesis에서 제대로 안 풀린거 같음.
    // 2D 배열은 툴이 메모리 구조로 해석을 못 함
    // 값이 0으로 들어가거나 무시되는 문제 waveform에 x로 도배됨
    // 그래서 하나하나 직접 매핑하는 노가다 방식 사용.
    assign a_w[0][0] = a_in_0;
    assign a_w[1][0] = a_in_1;
    assign a_w[2][0] = a_in_2;
    assign a_w[3][0] = a_in_3;

    assign b_w[0][0] = b_in_0;
    assign b_w[0][1] = b_in_1;
    assign b_w[0][2] = b_in_2;
    assign b_w[0][3] = b_in_3;

    assign p_w[0][0] = p_in_0;
    assign p_w[0][1] = p_in_1;
    assign p_w[0][2] = p_in_2;
    assign p_w[0][3] = p_in_3;

    genvar i, j;
    generate
        for (i=0; i<4; i=i+1) begin : ROW
            for (j=0; j<4; j=j+1) begin : COL
                pe_unit #(DATA_WIDTH, ACC_WIDTH) pe (
                    .clk(clk), .rst_n(rst_n), .drain(drain),
                    .a_in(a_w[i][j]), .b_in(b_w[i][j]), .p_in(p_w[i][j]),
                    .a_out(a_w[i][j+1]), .b_out(b_w[i+1][j]), .p_out(p_w[i+1][j])
                );
            end
        end
    endgenerate

    // 출력 포트도 배열 묶음 할당 피하기
    assign p_out_0 = p_w[4][0];
    assign p_out_1 = p_w[4][1];
    assign p_out_2 = p_w[4][2];
    assign p_out_3 = p_w[4][3];
endmodule
