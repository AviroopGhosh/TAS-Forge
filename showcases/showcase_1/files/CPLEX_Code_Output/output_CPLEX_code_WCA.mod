// Set the number of streams
int num_streams = 7;
range N_streams = 1..num_streams;

// The periodicity of streams
float T_period[N_streams] = [10000, 15000, 10000, 30000, 10000, 15000, 10000];

// The deadline of streams
float deadline[N_streams] = [10000, 15000, 10000, 30000, 10000, 15000, 10000];

// The hyperperiod of the network
int hp = 30000;

// The repetitions of streams within the hp
int repetitions[N_streams] = [3, 2, 3, 1, 3, 2, 3];

// The integer set for overlapping constraint
// int kmax = 3;

// The delta value in the network
float delta = 250.000000;

// Set the propagation delay
float prop_delay = 5.000000;

// Set the processing delay
//float proc_delay = 155.000000;

// Set the transmission delay
float trans_delay[N_streams] = [123.2, 123.2, 123.2, 123.2, 123.2, 123.2, 123.2];

// Set the ceil of the transmission delay
int trans_delay_var[N_streams] = [125, 125, 125, 125, 125, 125, 125];

// Set the L value per stream
float L[N_streams] = [283.2, 283.2, 283.2, 283.2, 283.2, 283.2, 283.2];

// Set the minimum e2e latency values per stream
float min_e2e[N_streams] = [411.4, 694.6, 977.8, 977.8, 977.8, 1261, 1261];

// Initialize the list of offsets
dvar int+ OFF_1_source5;
dvar int+ OFF_1_switch3;
dvar int+ OFF_2_source4;
dvar int+ OFF_2_switch2;
dvar int+ OFF_2_switch3;
dvar int+ OFF_3_source5;
dvar int+ OFF_3_switch3;
dvar int+ OFF_3_switch4;
dvar int+ OFF_3_switch5;
dvar int+ OFF_4_source2;
dvar int+ OFF_4_switch1;
dvar int+ OFF_4_switch2;
dvar int+ OFF_4_switch3;
dvar int+ OFF_5_source1;
dvar int+ OFF_5_switch1;
dvar int+ OFF_5_switch2;
dvar int+ OFF_5_switch3;
dvar int+ OFF_6_source2;
dvar int+ OFF_6_switch1;
dvar int+ OFF_6_switch2;
dvar int+ OFF_6_switch3;
dvar int+ OFF_6_switch4;
dvar int+ OFF_7_source3;
dvar int+ OFF_7_switch1;
dvar int+ OFF_7_switch2;
dvar int+ OFF_7_switch3;
dvar int+ OFF_7_switch4;


// Initialize the end-to-end latency
dvar float+ lambda_1;
dvar float+ lambda_2;
dvar float+ lambda_3;
dvar float+ lambda_4;
dvar float+ lambda_5;
dvar float+ lambda_6;
dvar float+ lambda_7;


// The minimization problem
minimize (lambda_1 - min_e2e[1]) + (lambda_2 - min_e2e[2]) + (lambda_3 - min_e2e[3]) + (lambda_4 - min_e2e[4]) + (lambda_5 - min_e2e[5]) + (lambda_6 - min_e2e[6]) + (lambda_7 - min_e2e[7]);

subject to {

// State the boundary conditions, the lower-bound and upper-bound

// Boundary conditions for Stream 1
0 <= OFF_1_source5 <= hp;
0 <= OFF_1_switch3 <= hp;

// Boundary conditions for Stream 2
0 <= OFF_2_source4 <= hp;
0 <= OFF_2_switch2 <= hp;
0 <= OFF_2_switch3 <= hp;

// Boundary conditions for Stream 3
0 <= OFF_3_source5 <= hp;
0 <= OFF_3_switch3 <= hp;
0 <= OFF_3_switch4 <= hp;
0 <= OFF_3_switch5 <= hp;

// Boundary conditions for Stream 4
0 <= OFF_4_source2 <= hp;
0 <= OFF_4_switch1 <= hp;
0 <= OFF_4_switch2 <= hp;
0 <= OFF_4_switch3 <= hp;

// Boundary conditions for Stream 5
0 <= OFF_5_source1 <= hp;
0 <= OFF_5_switch1 <= hp;
0 <= OFF_5_switch2 <= hp;
0 <= OFF_5_switch3 <= hp;

// Boundary conditions for Stream 6
0 <= OFF_6_source2 <= hp;
0 <= OFF_6_switch1 <= hp;
0 <= OFF_6_switch2 <= hp;
0 <= OFF_6_switch3 <= hp;
0 <= OFF_6_switch4 <= hp;

// Boundary conditions for Stream 7
0 <= OFF_7_source3 <= hp;
0 <= OFF_7_switch1 <= hp;
0 <= OFF_7_switch2 <= hp;
0 <= OFF_7_switch3 <= hp;
0 <= OFF_7_switch4 <= hp;

// The overlapping constraint

// The overlapping constraint: To prevent overlaps from streams from the same source

// The route within source2
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
maxl(trans_delay_var[4],trans_delay_var[6]) <= abs(OFF_4_source2 - OFF_6_source2) <= hp - 1;
}

// The route within source5
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[3]-1) {
maxl(trans_delay_var[1],trans_delay_var[3]) <= abs(OFF_1_source5 - OFF_3_source5) <= hp - 1;
}

// The overlapping constraint: To prevent overlaps between streams in the same switch

// Port of switch1 towards switch2
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch1 + (alpha - 1)*T_period[4]) - (OFF_5_switch1 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
abs((OFF_4_switch1 + (alpha - 1)*T_period[4]) - (OFF_6_switch1 + (beta - 1)*T_period[6])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[7]-1) {
abs((OFF_4_switch1 + (alpha - 1)*T_period[4]) - (OFF_7_switch1 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[6]-1) {
abs((OFF_5_switch1 + (alpha - 1)*T_period[5]) - (OFF_6_switch1 + (beta - 1)*T_period[6])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[7]-1) {
abs((OFF_5_switch1 + (alpha - 1)*T_period[5]) - (OFF_7_switch1 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
abs((OFF_6_switch1 + (alpha - 1)*T_period[6]) - (OFF_7_switch1 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}

// Port of switch2 towards switch3
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
abs((OFF_2_switch2 + (alpha - 1)*T_period[2]) - (OFF_4_switch2 + (beta - 1)*T_period[4])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
abs((OFF_2_switch2 + (alpha - 1)*T_period[2]) - (OFF_5_switch2 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[6]-1) {
abs((OFF_2_switch2 + (alpha - 1)*T_period[2]) - (OFF_6_switch2 + (beta - 1)*T_period[6])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[7]-1) {
abs((OFF_2_switch2 + (alpha - 1)*T_period[2]) - (OFF_7_switch2 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch2 + (alpha - 1)*T_period[4]) - (OFF_5_switch2 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
abs((OFF_4_switch2 + (alpha - 1)*T_period[4]) - (OFF_6_switch2 + (beta - 1)*T_period[6])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[7]-1) {
abs((OFF_4_switch2 + (alpha - 1)*T_period[4]) - (OFF_7_switch2 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[6]-1) {
abs((OFF_5_switch2 + (alpha - 1)*T_period[5]) - (OFF_6_switch2 + (beta - 1)*T_period[6])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[7]-1) {
abs((OFF_5_switch2 + (alpha - 1)*T_period[5]) - (OFF_7_switch2 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
abs((OFF_6_switch2 + (alpha - 1)*T_period[6]) - (OFF_7_switch2 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}

// Port of switch3 towards switch4
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[6]-1) {
abs((OFF_3_switch3 + (alpha - 1)*T_period[3]) - (OFF_6_switch3 + (beta - 1)*T_period[6])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[7]-1) {
abs((OFF_3_switch3 + (alpha - 1)*T_period[3]) - (OFF_7_switch3 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
abs((OFF_6_switch3 + (alpha - 1)*T_period[6]) - (OFF_7_switch3 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}

// Port of switch3 towards sink1
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[2]-1) {
abs((OFF_1_switch3 + (alpha - 1)*T_period[1]) - (OFF_2_switch3 + (beta - 1)*T_period[2])) <= 1*(hp - 1);
}

// Port of switch3 towards sink4
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch3 + (alpha - 1)*T_period[4]) - (OFF_5_switch3 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}

// Port of switch4 towards sink2
forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
abs((OFF_6_switch4 + (alpha - 1)*T_period[6]) - (OFF_7_switch4 + (beta - 1)*T_period[7])) <= 1*(hp - 1);
}

// Flow transmission constraint: The difference between consecutive offsets

// Stream 1
OFF_1_switch3 >= OFF_1_source5 + ceil(L[1] - 1*delta) - 1;
// Stream 2
OFF_2_switch2 >= OFF_2_source4 + ceil(L[2] - 1*delta) - 1;
OFF_2_switch3 >= OFF_2_switch2 + ceil(L[2] - 0*delta) - 1;
// Stream 3
OFF_3_switch3 >= OFF_3_source5 + ceil(L[3] - 1*delta) - 1;
OFF_3_switch4 >= OFF_3_switch3 + ceil(L[3] - 0*delta) - 1;
OFF_3_switch5 >= OFF_3_switch4 + ceil(L[3] - 0*delta) - 1;
// Stream 4
OFF_4_switch1 >= OFF_4_source2 + ceil(L[4] - 1*delta) - 1;
OFF_4_switch2 >= OFF_4_switch1 + ceil(L[4] - 0*delta) - 1;
OFF_4_switch3 >= OFF_4_switch2 + ceil(L[4] - 0*delta) - 1;
// Stream 5
OFF_5_switch1 >= OFF_5_source1 + ceil(L[5] - 1*delta) - 1;
OFF_5_switch2 >= OFF_5_switch1 + ceil(L[5] - 0*delta) - 1;
OFF_5_switch3 >= OFF_5_switch2 + ceil(L[5] - 0*delta) - 1;
// Stream 6
OFF_6_switch1 >= OFF_6_source2 + ceil(L[6] - 1*delta) - 1;
OFF_6_switch2 >= OFF_6_switch1 + ceil(L[6] - 0*delta) - 1;
OFF_6_switch3 >= OFF_6_switch2 + ceil(L[6] - 0*delta) - 1;
OFF_6_switch4 >= OFF_6_switch3 + ceil(L[6] - 0*delta) - 1;
// Stream 7
OFF_7_switch1 >= OFF_7_source3 + ceil(L[7] - 1*delta) - 1;
OFF_7_switch2 >= OFF_7_switch1 + ceil(L[7] - 0*delta) - 1;
OFF_7_switch3 >= OFF_7_switch2 + ceil(L[7] - 0*delta) - 1;
OFF_7_switch4 >= OFF_7_switch3 + ceil(L[7] - 0*delta) - 1;

// The scheduling duration constraint: Switch schedules should not overlap
// Port of switch1 towards switch2
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch1 - OFF_4_switch1 <= (alpha*T_period[4] - beta*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1) ||
OFF_4_switch1 - OFF_5_switch1 <= (beta*T_period[5] - alpha*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
OFF_6_switch1 - OFF_4_switch1 <= (alpha*T_period[4] - beta*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1) ||
OFF_4_switch1 - OFF_6_switch1 <= (beta*T_period[6] - alpha*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch1 - OFF_4_switch1 <= (alpha*T_period[4] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_4_switch1 - OFF_7_switch1 <= (beta*T_period[7] - alpha*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[6]-1) {
OFF_6_switch1 - OFF_5_switch1 <= (alpha*T_period[5] - beta*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1) ||
OFF_5_switch1 - OFF_6_switch1 <= (beta*T_period[6] - alpha*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch1 - OFF_5_switch1 <= (alpha*T_period[5] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_5_switch1 - OFF_7_switch1 <= (beta*T_period[7] - alpha*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1);
}

forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch1 - OFF_6_switch1 <= (alpha*T_period[6] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_6_switch1 - OFF_7_switch1 <= (beta*T_period[7] - alpha*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1);
}

// Port of switch2 towards switch3
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
OFF_4_switch2 - OFF_2_switch2 <= (alpha*T_period[2] - beta*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1) ||
OFF_2_switch2 - OFF_4_switch2 <= (beta*T_period[4] - alpha*T_period[2]) - ceil(trans_delay[2] + 2*delta + 1);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch2 - OFF_2_switch2 <= (alpha*T_period[2] - beta*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1) ||
OFF_2_switch2 - OFF_5_switch2 <= (beta*T_period[5] - alpha*T_period[2]) - ceil(trans_delay[2] + 2*delta + 1);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[6]-1) {
OFF_6_switch2 - OFF_2_switch2 <= (alpha*T_period[2] - beta*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1) ||
OFF_2_switch2 - OFF_6_switch2 <= (beta*T_period[6] - alpha*T_period[2]) - ceil(trans_delay[2] + 2*delta + 1);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch2 - OFF_2_switch2 <= (alpha*T_period[2] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_2_switch2 - OFF_7_switch2 <= (beta*T_period[7] - alpha*T_period[2]) - ceil(trans_delay[2] + 2*delta + 1);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch2 - OFF_4_switch2 <= (alpha*T_period[4] - beta*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1) ||
OFF_4_switch2 - OFF_5_switch2 <= (beta*T_period[5] - alpha*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
OFF_6_switch2 - OFF_4_switch2 <= (alpha*T_period[4] - beta*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1) ||
OFF_4_switch2 - OFF_6_switch2 <= (beta*T_period[6] - alpha*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch2 - OFF_4_switch2 <= (alpha*T_period[4] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_4_switch2 - OFF_7_switch2 <= (beta*T_period[7] - alpha*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[6]-1) {
OFF_6_switch2 - OFF_5_switch2 <= (alpha*T_period[5] - beta*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1) ||
OFF_5_switch2 - OFF_6_switch2 <= (beta*T_period[6] - alpha*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch2 - OFF_5_switch2 <= (alpha*T_period[5] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_5_switch2 - OFF_7_switch2 <= (beta*T_period[7] - alpha*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1);
}

forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch2 - OFF_6_switch2 <= (alpha*T_period[6] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_6_switch2 - OFF_7_switch2 <= (beta*T_period[7] - alpha*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1);
}

// Port of switch3 towards switch4
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[6]-1) {
OFF_6_switch3 - OFF_3_switch3 <= (alpha*T_period[3] - beta*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1) ||
OFF_3_switch3 - OFF_6_switch3 <= (beta*T_period[6] - alpha*T_period[3]) - ceil(trans_delay[3] + 2*delta + 1);
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch3 - OFF_3_switch3 <= (alpha*T_period[3] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_3_switch3 - OFF_7_switch3 <= (beta*T_period[7] - alpha*T_period[3]) - ceil(trans_delay[3] + 2*delta + 1);
}

forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch3 - OFF_6_switch3 <= (alpha*T_period[6] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_6_switch3 - OFF_7_switch3 <= (beta*T_period[7] - alpha*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1);
}

// Port of switch3 towards sink1
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[2]-1) {
OFF_2_switch3 - OFF_1_switch3 <= (alpha*T_period[1] - beta*T_period[2]) - ceil(trans_delay[2] + 2*delta + 1) ||
OFF_1_switch3 - OFF_2_switch3 <= (beta*T_period[2] - alpha*T_period[1]) - ceil(trans_delay[1] + 2*delta + 1);
}

// Port of switch3 towards sink4
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch3 - OFF_4_switch3 <= (alpha*T_period[4] - beta*T_period[5]) - ceil(trans_delay[5] + 2*delta + 1) ||
OFF_4_switch3 - OFF_5_switch3 <= (beta*T_period[5] - alpha*T_period[4]) - ceil(trans_delay[4] + 2*delta + 1);
}

// Port of switch4 towards sink2
forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_7_switch4 - OFF_6_switch4 <= (alpha*T_period[6] - beta*T_period[7]) - ceil(trans_delay[7] + 2*delta + 1) ||
OFF_6_switch4 - OFF_7_switch4 <= (beta*T_period[7] - alpha*T_period[6]) - ceil(trans_delay[6] + 2*delta + 1);
}


// The frame arrival constraint

// Switch 1
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch1 + alpha*T_period[4] <= OFF_5_source1 + beta*T_period[5] + (L[5] - delta)||
OFF_5_switch1 + beta*T_period[5] <= OFF_4_source2 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
OFF_4_switch1 + alpha*T_period[4] <= OFF_6_source2 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch1 + beta*T_period[6] <= OFF_4_source2 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[7]-1) {
OFF_4_switch1 + alpha*T_period[4] <= OFF_7_source3 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch1 + beta*T_period[7] <= OFF_4_source2 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[6]-1) {
OFF_5_switch1 + alpha*T_period[5] <= OFF_6_source2 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch1 + beta*T_period[6] <= OFF_5_source1 + alpha*T_period[5] + (L[5] - delta);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[7]-1) {
OFF_5_switch1 + alpha*T_period[5] <= OFF_7_source3 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch1 + beta*T_period[7] <= OFF_5_source1 + alpha*T_period[5] + (L[5] - delta);
}

forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_6_switch1 + alpha*T_period[6] <= OFF_7_source3 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch1 + beta*T_period[7] <= OFF_6_source2 + alpha*T_period[6] + (L[6] - delta);
}

// Switch 2
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
OFF_2_switch2 + alpha*T_period[2] <= OFF_4_switch1 + beta*T_period[4] + (L[4] - delta)||
OFF_4_switch2 + beta*T_period[4] <= OFF_2_source4 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
OFF_2_switch2 + alpha*T_period[2] <= OFF_5_switch1 + beta*T_period[5] + (L[5] - delta)||
OFF_5_switch2 + beta*T_period[5] <= OFF_2_source4 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[6]-1) {
OFF_2_switch2 + alpha*T_period[2] <= OFF_6_switch1 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch2 + beta*T_period[6] <= OFF_2_source4 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[7]-1) {
OFF_2_switch2 + alpha*T_period[2] <= OFF_7_switch1 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch2 + beta*T_period[7] <= OFF_2_source4 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch2 + alpha*T_period[4] <= OFF_5_switch1 + beta*T_period[5] + (L[5] - delta)||
OFF_5_switch2 + beta*T_period[5] <= OFF_4_switch1 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
OFF_4_switch2 + alpha*T_period[4] <= OFF_6_switch1 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch2 + beta*T_period[6] <= OFF_4_switch1 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[7]-1) {
OFF_4_switch2 + alpha*T_period[4] <= OFF_7_switch1 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch2 + beta*T_period[7] <= OFF_4_switch1 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[6]-1) {
OFF_5_switch2 + alpha*T_period[5] <= OFF_6_switch1 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch2 + beta*T_period[6] <= OFF_5_switch1 + alpha*T_period[5] + (L[5] - delta);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[7]-1) {
OFF_5_switch2 + alpha*T_period[5] <= OFF_7_switch1 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch2 + beta*T_period[7] <= OFF_5_switch1 + alpha*T_period[5] + (L[5] - delta);
}

forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_6_switch2 + alpha*T_period[6] <= OFF_7_switch1 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch2 + beta*T_period[7] <= OFF_6_switch1 + alpha*T_period[6] + (L[6] - delta);
}

// Switch 3
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[2]-1) {
OFF_1_switch3 + alpha*T_period[1] <= OFF_2_switch2 + beta*T_period[2] + (L[2] - delta)||
OFF_2_switch3 + beta*T_period[2] <= OFF_1_source5 + alpha*T_period[1] + (L[1] - delta);
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[3]-1) {
OFF_1_switch3 + alpha*T_period[1] <= OFF_3_source5 + beta*T_period[3] + (L[3] - delta)||
OFF_3_switch3 + beta*T_period[3] <= OFF_1_source5 + alpha*T_period[1] + (L[1] - delta);
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[4]-1) {
OFF_1_switch3 + alpha*T_period[1] <= OFF_4_switch2 + beta*T_period[4] + (L[4] - delta)||
OFF_4_switch3 + beta*T_period[4] <= OFF_1_source5 + alpha*T_period[1] + (L[1] - delta);
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[5]-1) {
OFF_1_switch3 + alpha*T_period[1] <= OFF_5_switch2 + beta*T_period[5] + (L[5] - delta)||
OFF_5_switch3 + beta*T_period[5] <= OFF_1_source5 + alpha*T_period[1] + (L[1] - delta);
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[6]-1) {
OFF_1_switch3 + alpha*T_period[1] <= OFF_6_switch2 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch3 + beta*T_period[6] <= OFF_1_source5 + alpha*T_period[1] + (L[1] - delta);
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[7]-1) {
OFF_1_switch3 + alpha*T_period[1] <= OFF_7_switch2 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch3 + beta*T_period[7] <= OFF_1_source5 + alpha*T_period[1] + (L[1] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[3]-1) {
OFF_2_switch3 + alpha*T_period[2] <= OFF_3_source5 + beta*T_period[3] + (L[3] - delta)||
OFF_3_switch3 + beta*T_period[3] <= OFF_2_switch2 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
OFF_2_switch3 + alpha*T_period[2] <= OFF_4_switch2 + beta*T_period[4] + (L[4] - delta)||
OFF_4_switch3 + beta*T_period[4] <= OFF_2_switch2 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
OFF_2_switch3 + alpha*T_period[2] <= OFF_5_switch2 + beta*T_period[5] + (L[5] - delta)||
OFF_5_switch3 + beta*T_period[5] <= OFF_2_switch2 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[6]-1) {
OFF_2_switch3 + alpha*T_period[2] <= OFF_6_switch2 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch3 + beta*T_period[6] <= OFF_2_switch2 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[7]-1) {
OFF_2_switch3 + alpha*T_period[2] <= OFF_7_switch2 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch3 + beta*T_period[7] <= OFF_2_switch2 + alpha*T_period[2] + (L[2] - delta);
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
OFF_3_switch3 + alpha*T_period[3] <= OFF_4_switch2 + beta*T_period[4] + (L[4] - delta)||
OFF_4_switch3 + beta*T_period[4] <= OFF_3_source5 + alpha*T_period[3] + (L[3] - delta);
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
OFF_3_switch3 + alpha*T_period[3] <= OFF_5_switch2 + beta*T_period[5] + (L[5] - delta)||
OFF_5_switch3 + beta*T_period[5] <= OFF_3_source5 + alpha*T_period[3] + (L[3] - delta);
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[6]-1) {
OFF_3_switch3 + alpha*T_period[3] <= OFF_6_switch2 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch3 + beta*T_period[6] <= OFF_3_source5 + alpha*T_period[3] + (L[3] - delta);
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[7]-1) {
OFF_3_switch3 + alpha*T_period[3] <= OFF_7_switch2 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch3 + beta*T_period[7] <= OFF_3_source5 + alpha*T_period[3] + (L[3] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch3 + alpha*T_period[4] <= OFF_5_switch2 + beta*T_period[5] + (L[5] - delta)||
OFF_5_switch3 + beta*T_period[5] <= OFF_4_switch2 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[6]-1) {
OFF_4_switch3 + alpha*T_period[4] <= OFF_6_switch2 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch3 + beta*T_period[6] <= OFF_4_switch2 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[7]-1) {
OFF_4_switch3 + alpha*T_period[4] <= OFF_7_switch2 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch3 + beta*T_period[7] <= OFF_4_switch2 + alpha*T_period[4] + (L[4] - delta);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[6]-1) {
OFF_5_switch3 + alpha*T_period[5] <= OFF_6_switch2 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch3 + beta*T_period[6] <= OFF_5_switch2 + alpha*T_period[5] + (L[5] - delta);
}

forall(alpha in 0..repetitions[5]-1, beta in 0..repetitions[7]-1) {
OFF_5_switch3 + alpha*T_period[5] <= OFF_7_switch2 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch3 + beta*T_period[7] <= OFF_5_switch2 + alpha*T_period[5] + (L[5] - delta);
}

forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_6_switch3 + alpha*T_period[6] <= OFF_7_switch2 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch3 + beta*T_period[7] <= OFF_6_switch2 + alpha*T_period[6] + (L[6] - delta);
}

// Switch 4
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[6]-1) {
OFF_3_switch4 + alpha*T_period[3] <= OFF_6_switch3 + beta*T_period[6] + (L[6] - delta)||
OFF_6_switch4 + beta*T_period[6] <= OFF_3_switch3 + alpha*T_period[3] + (L[3] - delta);
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[7]-1) {
OFF_3_switch4 + alpha*T_period[3] <= OFF_7_switch3 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch4 + beta*T_period[7] <= OFF_3_switch3 + alpha*T_period[3] + (L[3] - delta);
}

forall(alpha in 0..repetitions[6]-1, beta in 0..repetitions[7]-1) {
OFF_6_switch4 + alpha*T_period[6] <= OFF_7_switch3 + beta*T_period[7] + (L[7] - delta)||
OFF_7_switch4 + beta*T_period[7] <= OFF_6_switch3 + alpha*T_period[6] + (L[6] - delta);
}

// Switch 5

 // The e2e latency: lamda = last_offset.OFF + trans_delay(switch_ID) - first_offset.OFF
lambda_1 == OFF_1_switch3  - OFF_1_source5 + (trans_delay[1] + prop_delay + delta);
lambda_2 == OFF_2_switch3  - OFF_2_source4 + (trans_delay[2] + prop_delay + delta);
lambda_3 == OFF_3_switch5  - OFF_3_source5 + (trans_delay[3] + prop_delay + delta);
lambda_4 == OFF_4_switch3  - OFF_4_source2 + (trans_delay[4] + prop_delay + delta);
lambda_5 == OFF_5_switch3  - OFF_5_source1 + (trans_delay[5] + prop_delay + delta);
lambda_6 == OFF_6_switch4  - OFF_6_source2 + (trans_delay[6] + prop_delay + delta);
lambda_7 == OFF_7_switch4  - OFF_7_source3 + (trans_delay[7] + prop_delay + delta);

// The e2e latency boundaries
min_e2e[1] == lambda_1 <= deadline[1];
min_e2e[2] == lambda_2 <= deadline[2];
min_e2e[3] == lambda_3 <= deadline[3];
min_e2e[4] == lambda_4 <= deadline[4];
min_e2e[5] == lambda_5 <= deadline[5];
min_e2e[6] == lambda_6 <= deadline[6];
min_e2e[7] == lambda_7 <= deadline[7];
}