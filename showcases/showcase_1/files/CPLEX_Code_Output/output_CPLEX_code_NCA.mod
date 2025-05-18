// Set the number of streams
int num_streams = 5;
range N_streams = 1..num_streams;

// The periodicity of streams
float T_period[N_streams] = [1500, 1500, 1000, 3000, 1000];

// The deadline of streams
float deadline[N_streams] = [1500, 1500, 1000, 3000, 1000];

// The hyperperiod of the network
int hp = 3000;

// The repetitions of streams within the hp
int repetitions[N_streams] = [2, 2, 3, 1, 3];

// The integer set for overlapping constraint
// int kmax = 3;

// The clock drift values of devices in the network
float p_switch1 = 0.000000;
float p_switch2 = 0.000006;
float p_switch3 = -0.000008;
float p_switch4 = -0.000002;
float p_switch5 = 0.000009;
float p_source1 = 0.000006;
float p_source2 = 0.000010;
float p_source3 = 0.000003;
float p_source4 = -0.000010;
float p_source5 = 0.000007;
float p_GM1 = 0.000000;

// The synchronization periodicity
float T_sync = 1250000.000000;

// Set the propagation delay
float prop_delay = 0.500000;

// Set the processing delay
//float proc_delay = 15.500000;

// Set the transmission delay
float trans_delay[N_streams] = [12.32, 12.32, 12.32, 12.32, 12.32];

// Set the ceil of the transmission delay
int trans_delay_var[N_streams] = [14, 14, 14, 14, 14];

// Set the L value per stream
float L[N_streams] = [28.32, 28.32, 28.32, 28.32, 28.32];

// Set the minimum e2e latency values per stream
float min_e2e[N_streams] = [69.46, 97.78, 126.1, 154.42, 154.42];

// Initialize the list of offsets
dvar int+ OFF_1_source5;
dvar int+ OFF_1_switch2;
dvar int+ OFF_1_switch3;
dvar int+ OFF_2_source2;
dvar int+ OFF_2_switch1;
dvar int+ OFF_2_switch2;
dvar int+ OFF_2_switch3;
dvar int+ OFF_3_source4;
dvar int+ OFF_3_switch1;
dvar int+ OFF_3_switch2;
dvar int+ OFF_3_switch3;
dvar int+ OFF_3_switch4;
dvar int+ OFF_4_source1;
dvar int+ OFF_4_switch1;
dvar int+ OFF_4_switch2;
dvar int+ OFF_4_switch3;
dvar int+ OFF_4_switch4;
dvar int+ OFF_4_switch5;
dvar int+ OFF_5_source3;
dvar int+ OFF_5_switch1;
dvar int+ OFF_5_switch2;
dvar int+ OFF_5_switch3;
dvar int+ OFF_5_switch4;
dvar int+ OFF_5_switch5;


// Initialize the end-to-end latency
dvar float+ lambda_1;
dvar float+ lambda_2;
dvar float+ lambda_3;
dvar float+ lambda_4;
dvar float+ lambda_5;


// The minimization problem
minimize (lambda_1 - min_e2e[1]) + (lambda_2 - min_e2e[2]) + (lambda_3 - min_e2e[3]) + (lambda_4 - min_e2e[4]) + (lambda_5 - min_e2e[5]);

subject to {

// State the boundary conditions, the lower-bound and upper-bound

// Boundary conditions for Stream 1
0 <= OFF_1_source5 <= hp-1;
0 <= OFF_1_switch2 <= hp-1;
0 <= OFF_1_switch3 <= hp-1;

// Boundary conditions for Stream 2
0 <= OFF_2_source2 <= hp-1;
0 <= OFF_2_switch1 <= hp-1;
0 <= OFF_2_switch2 <= hp-1;
0 <= OFF_2_switch3 <= hp-1;

// Boundary conditions for Stream 3
0 <= OFF_3_source4 <= hp-1;
0 <= OFF_3_switch1 <= hp-1;
0 <= OFF_3_switch2 <= hp-1;
0 <= OFF_3_switch3 <= hp-1;
0 <= OFF_3_switch4 <= hp-1;

// Boundary conditions for Stream 4
0 <= OFF_4_source1 <= hp-1;
0 <= OFF_4_switch1 <= hp-1;
0 <= OFF_4_switch2 <= hp-1;
0 <= OFF_4_switch3 <= hp-1;
0 <= OFF_4_switch4 <= hp-1;
0 <= OFF_4_switch5 <= hp-1;

// Boundary conditions for Stream 5
0 <= OFF_5_source3 <= hp-1;
0 <= OFF_5_switch1 <= hp-1;
0 <= OFF_5_switch2 <= hp-1;
0 <= OFF_5_switch3 <= hp-1;
0 <= OFF_5_switch4 <= hp-1;
0 <= OFF_5_switch5 <= hp-1;

// The overlapping constraint

// The overlapping constraint: To prevent overlaps from streams from the same source

// The overlapping constraint: To prevent overlaps between streams in the same switch

// Port of switch1 towards switch2
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[3]-1) {
abs((OFF_2_switch1 + (alpha - 1)*T_period[2]) - (OFF_3_switch1 + (beta - 1)*T_period[3])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
abs((OFF_2_switch1 + (alpha - 1)*T_period[2]) - (OFF_4_switch1 + (beta - 1)*T_period[4])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
abs((OFF_2_switch1 + (alpha - 1)*T_period[2]) - (OFF_5_switch1 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
abs((OFF_3_switch1 + (alpha - 1)*T_period[3]) - (OFF_4_switch1 + (beta - 1)*T_period[4])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
abs((OFF_3_switch1 + (alpha - 1)*T_period[3]) - (OFF_5_switch1 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch1 + (alpha - 1)*T_period[4]) - (OFF_5_switch1 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}

// Port of switch2 towards switch3
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[2]-1) {
abs((OFF_1_switch2 + (alpha - 1)*T_period[1]) - (OFF_2_switch2 + (beta - 1)*T_period[2])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[3]-1) {
abs((OFF_1_switch2 + (alpha - 1)*T_period[1]) - (OFF_3_switch2 + (beta - 1)*T_period[3])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[4]-1) {
abs((OFF_1_switch2 + (alpha - 1)*T_period[1]) - (OFF_4_switch2 + (beta - 1)*T_period[4])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[5]-1) {
abs((OFF_1_switch2 + (alpha - 1)*T_period[1]) - (OFF_5_switch2 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[3]-1) {
abs((OFF_2_switch2 + (alpha - 1)*T_period[2]) - (OFF_3_switch2 + (beta - 1)*T_period[3])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
abs((OFF_2_switch2 + (alpha - 1)*T_period[2]) - (OFF_4_switch2 + (beta - 1)*T_period[4])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
abs((OFF_2_switch2 + (alpha - 1)*T_period[2]) - (OFF_5_switch2 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
abs((OFF_3_switch2 + (alpha - 1)*T_period[3]) - (OFF_4_switch2 + (beta - 1)*T_period[4])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
abs((OFF_3_switch2 + (alpha - 1)*T_period[3]) - (OFF_5_switch2 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch2 + (alpha - 1)*T_period[4]) - (OFF_5_switch2 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}

// Port of switch3 towards switch4
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
abs((OFF_3_switch3 + (alpha - 1)*T_period[3]) - (OFF_4_switch3 + (beta - 1)*T_period[4])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
abs((OFF_3_switch3 + (alpha - 1)*T_period[3]) - (OFF_5_switch3 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch3 + (alpha - 1)*T_period[4]) - (OFF_5_switch3 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}

// Port of switch4 towards switch5
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch4 + (alpha - 1)*T_period[4]) - (OFF_5_switch4 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}

// Port of switch5 towards sink3
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
abs((OFF_4_switch5 + (alpha - 1)*T_period[4]) - (OFF_5_switch5 + (beta - 1)*T_period[5])) <= 1*(hp - 1);
}

// Consecutive offset constraint: The difference between consecutive offsets

// Stream 1
OFF_1_switch2 >= OFF_1_source5 + floor(L[1] + minl(0, (p_switch2 - p_source5)*T_sync, (p_GM1 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync));
OFF_1_switch3 >= OFF_1_switch2 + floor(L[1]+ minl(0, (p_switch3 - p_source5)*T_sync, (p_GM1 - p_source5)*T_sync, (p_switch3 - p_GM1)*T_sync) - minl(0, (p_switch2 - p_source5)*T_sync, (p_GM1 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync));
// Stream 2
OFF_2_switch1 >= OFF_2_source2 + floor(L[2] + minl(0, (p_switch1 - p_source2)*T_sync, (p_GM1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_2_switch2 >= OFF_2_switch1 + floor(L[2]+ minl(0, (p_switch2 - p_source2)*T_sync, (p_GM1 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync) - minl(0, (p_switch1 - p_source2)*T_sync, (p_GM1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_2_switch3 >= OFF_2_switch2 + floor(L[2]+ minl(0, (p_switch3 - p_source2)*T_sync, (p_GM1 - p_source2)*T_sync, (p_switch3 - p_GM1)*T_sync) - minl(0, (p_switch2 - p_source2)*T_sync, (p_GM1 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync));
// Stream 3
OFF_3_switch1 >= OFF_3_source4 + floor(L[3] + minl(0, (p_switch1 - p_source4)*T_sync, (p_GM1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_3_switch2 >= OFF_3_switch1 + floor(L[3]+ minl(0, (p_switch2 - p_source4)*T_sync, (p_GM1 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync) - minl(0, (p_switch1 - p_source4)*T_sync, (p_GM1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_3_switch3 >= OFF_3_switch2 + floor(L[3]+ minl(0, (p_switch3 - p_source4)*T_sync, (p_GM1 - p_source4)*T_sync, (p_switch3 - p_GM1)*T_sync) - minl(0, (p_switch2 - p_source4)*T_sync, (p_GM1 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync));
OFF_3_switch4 >= OFF_3_switch3 + floor(L[3]+ minl(0, (p_switch4 - p_source4)*T_sync, (p_GM1 - p_source4)*T_sync, (p_switch4 - p_GM1)*T_sync) - minl(0, (p_switch3 - p_source4)*T_sync, (p_GM1 - p_source4)*T_sync, (p_switch3 - p_GM1)*T_sync));
// Stream 4
OFF_4_switch1 >= OFF_4_source1 + floor(L[4] + minl(0, (p_switch1 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_4_switch2 >= OFF_4_switch1 + floor(L[4]+ minl(0, (p_switch2 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync) - minl(0, (p_switch1 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_4_switch3 >= OFF_4_switch2 + floor(L[4]+ minl(0, (p_switch3 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch3 - p_GM1)*T_sync) - minl(0, (p_switch2 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync));
OFF_4_switch4 >= OFF_4_switch3 + floor(L[4]+ minl(0, (p_switch4 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch4 - p_GM1)*T_sync) - minl(0, (p_switch3 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch3 - p_GM1)*T_sync));
OFF_4_switch5 >= OFF_4_switch4 + floor(L[4]+ minl(0, (p_switch5 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch5 - p_GM1)*T_sync) - minl(0, (p_switch4 - p_source1)*T_sync, (p_GM1 - p_source1)*T_sync, (p_switch4 - p_GM1)*T_sync));
// Stream 5
OFF_5_switch1 >= OFF_5_source3 + floor(L[5] + minl(0, (p_switch1 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_5_switch2 >= OFF_5_switch1 + floor(L[5]+ minl(0, (p_switch2 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync) - minl(0, (p_switch1 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync));
OFF_5_switch3 >= OFF_5_switch2 + floor(L[5]+ minl(0, (p_switch3 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch3 - p_GM1)*T_sync) - minl(0, (p_switch2 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync));
OFF_5_switch4 >= OFF_5_switch3 + floor(L[5]+ minl(0, (p_switch4 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch4 - p_GM1)*T_sync) - minl(0, (p_switch3 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch3 - p_GM1)*T_sync));
OFF_5_switch5 >= OFF_5_switch4 + floor(L[5]+ minl(0, (p_switch5 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch5 - p_GM1)*T_sync) - minl(0, (p_switch4 - p_source3)*T_sync, (p_GM1 - p_source3)*T_sync, (p_switch4 - p_GM1)*T_sync));

// The scheduling duration constraint: Switch schedules should not overlap
// Port of switch1 towards switch2
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[3]-1) {
OFF_3_switch1 - OFF_2_switch1 <= (alpha*T_period[2] - beta*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ) ||
OFF_2_switch1 - OFF_3_switch1 <= (beta*T_period[3] - alpha*T_period[2])- ceil(trans_delay_var[2] - minl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync) + maxl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source2)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
OFF_4_switch1 - OFF_2_switch1 <= (alpha*T_period[2] - beta*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ) ||
OFF_2_switch1 - OFF_4_switch1 <= (beta*T_period[4] - alpha*T_period[2])- ceil(trans_delay_var[2] - minl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync) + maxl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source2)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch1 - OFF_2_switch1 <= (alpha*T_period[2] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_2_switch1 - OFF_5_switch1 <= (beta*T_period[5] - alpha*T_period[2])- ceil(trans_delay_var[2] - minl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync) + maxl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source2)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
OFF_4_switch1 - OFF_3_switch1 <= (alpha*T_period[3] - beta*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ) ||
OFF_3_switch1 - OFF_4_switch1 <= (beta*T_period[4] - alpha*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch1 - OFF_3_switch1 <= (alpha*T_period[3] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_3_switch1 - OFF_5_switch1 <= (beta*T_period[5] - alpha*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch1 - OFF_4_switch1 <= (alpha*T_period[4] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_4_switch1 - OFF_5_switch1 <= (beta*T_period[5] - alpha*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ); 
}

// Port of switch2 towards switch3
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[2]-1) {
OFF_2_switch2 - OFF_1_switch2 <= (alpha*T_period[1] - beta*T_period[2])- ceil(trans_delay_var[2] - minl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync) + maxl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source2)*T_sync) + 2 ) ||
OFF_1_switch2 - OFF_2_switch2 <= (beta*T_period[2] - alpha*T_period[1])- ceil(trans_delay_var[1] - minl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync) + maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source5)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[3]-1) {
OFF_3_switch2 - OFF_1_switch2 <= (alpha*T_period[1] - beta*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ) ||
OFF_1_switch2 - OFF_3_switch2 <= (beta*T_period[3] - alpha*T_period[1])- ceil(trans_delay_var[1] - minl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync) + maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source5)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[4]-1) {
OFF_4_switch2 - OFF_1_switch2 <= (alpha*T_period[1] - beta*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ) ||
OFF_1_switch2 - OFF_4_switch2 <= (beta*T_period[4] - alpha*T_period[1])- ceil(trans_delay_var[1] - minl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync) + maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source5)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch2 - OFF_1_switch2 <= (alpha*T_period[1] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_1_switch2 - OFF_5_switch2 <= (beta*T_period[5] - alpha*T_period[1])- ceil(trans_delay_var[1] - minl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync) + maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source5)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[3]-1) {
OFF_3_switch2 - OFF_2_switch2 <= (alpha*T_period[2] - beta*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ) ||
OFF_2_switch2 - OFF_3_switch2 <= (beta*T_period[3] - alpha*T_period[2])- ceil(trans_delay_var[2] - minl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync) + maxl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source2)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
OFF_4_switch2 - OFF_2_switch2 <= (alpha*T_period[2] - beta*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ) ||
OFF_2_switch2 - OFF_4_switch2 <= (beta*T_period[4] - alpha*T_period[2])- ceil(trans_delay_var[2] - minl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync) + maxl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source2)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch2 - OFF_2_switch2 <= (alpha*T_period[2] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_2_switch2 - OFF_5_switch2 <= (beta*T_period[5] - alpha*T_period[2])- ceil(trans_delay_var[2] - minl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync) + maxl(0, (p_switch2 - p_source2)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source2)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
OFF_4_switch2 - OFF_3_switch2 <= (alpha*T_period[3] - beta*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ) ||
OFF_3_switch2 - OFF_4_switch2 <= (beta*T_period[4] - alpha*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch2 - OFF_3_switch2 <= (alpha*T_period[3] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_3_switch2 - OFF_5_switch2 <= (beta*T_period[5] - alpha*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch2 - p_source4)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch2 - OFF_4_switch2 <= (alpha*T_period[4] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch2 - p_source3)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_4_switch2 - OFF_5_switch2 <= (beta*T_period[5] - alpha*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch2 - p_source1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ); 
}

// Port of switch3 towards switch4
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
OFF_4_switch3 - OFF_3_switch3 <= (alpha*T_period[3] - beta*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch3 - p_source1)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch3 - p_source1)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ) ||
OFF_3_switch3 - OFF_4_switch3 <= (beta*T_period[4] - alpha*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch3 - p_source4)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch3 - p_source4)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch3 - OFF_3_switch3 <= (alpha*T_period[3] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch3 - p_source3)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch3 - p_source3)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_3_switch3 - OFF_5_switch3 <= (beta*T_period[5] - alpha*T_period[3])- ceil(trans_delay_var[3] - minl(0, (p_switch3 - p_source4)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync) + maxl(0, (p_switch3 - p_source4)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 -p_source4)*T_sync) + 2 ); 
}

forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch3 - OFF_4_switch3 <= (alpha*T_period[4] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch3 - p_source3)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch3 - p_source3)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_4_switch3 - OFF_5_switch3 <= (beta*T_period[5] - alpha*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch3 - p_source1)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch3 - p_source1)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ); 
}

// Port of switch4 towards switch5
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch4 - OFF_4_switch4 <= (alpha*T_period[4] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch4 - p_source3)*T_sync, (p_switch4 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch4 - p_source3)*T_sync, (p_switch4 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_4_switch4 - OFF_5_switch4 <= (beta*T_period[5] - alpha*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch4 - p_source1)*T_sync, (p_switch4 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch4 - p_source1)*T_sync, (p_switch4 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ); 
}

// Port of switch5 towards sink3
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_5_switch5 - OFF_4_switch5 <= (alpha*T_period[4] - beta*T_period[5])- ceil(trans_delay_var[5] - minl(0, (p_switch5 - p_source3)*T_sync, (p_switch5 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync) + maxl(0, (p_switch5 - p_source3)*T_sync, (p_switch5 - p_GM1)*T_sync, (p_GM1 -p_source3)*T_sync) + 2 ) ||
OFF_4_switch5 - OFF_5_switch5 <= (beta*T_period[5] - alpha*T_period[4])- ceil(trans_delay_var[4] - minl(0, (p_switch5 - p_source1)*T_sync, (p_switch5 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync) + maxl(0, (p_switch5 - p_source1)*T_sync, (p_switch5 - p_GM1)*T_sync, (p_GM1 -p_source1)*T_sync) + 2 ); 
}


// The frame arrival constraint

// Port of switch1 towards switch2 
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[3]-1) {
OFF_2_switch1 + alpha*T_period[2] <= OFF_3_source4 + beta*T_period[3] +ceil(L[3] - maxl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync))||
OFF_3_switch1 + beta*T_period[3] <= OFF_2_source2 + alpha*T_period[2] +ceil(L[2] - maxl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync));
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
OFF_2_switch1 + alpha*T_period[2] <= OFF_4_source1 + beta*T_period[4] +ceil(L[4] - maxl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync))||
OFF_4_switch1 + beta*T_period[4] <= OFF_2_source2 + alpha*T_period[2] +ceil(L[2] - maxl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync));
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
OFF_2_switch1 + alpha*T_period[2] <= OFF_5_source3 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync))||
OFF_5_switch1 + beta*T_period[5] <= OFF_2_source2 + alpha*T_period[2] +ceil(L[2] - maxl(0, (p_switch1 - p_source2)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source2)*T_sync));
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
OFF_3_switch1 + alpha*T_period[3] <= OFF_4_source1 + beta*T_period[4] +ceil(L[4] - maxl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync))||
OFF_4_switch1 + beta*T_period[4] <= OFF_3_source4 + alpha*T_period[3] +ceil(L[3] - maxl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync));
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
OFF_3_switch1 + alpha*T_period[3] <= OFF_5_source3 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync))||
OFF_5_switch1 + beta*T_period[5] <= OFF_3_source4 + alpha*T_period[3] +ceil(L[3] - maxl(0, (p_switch1 - p_source4)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source4)*T_sync));
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch1 + alpha*T_period[4] <= OFF_5_source3 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch1 - p_source3)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source3)*T_sync))||
OFF_5_switch1 + beta*T_period[5] <= OFF_4_source1 + alpha*T_period[4] +ceil(L[4] - maxl(0, (p_switch1 - p_source1)*T_sync, (p_switch1 - p_GM1)*T_sync, (p_GM1 - p_source1)*T_sync));
}

// Port of switch2 towards switch3 
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[2]-1) {
OFF_1_switch2 + alpha*T_period[1] <= OFF_2_switch1 + beta*T_period[2] +ceil(L[2] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_2_switch2 + beta*T_period[2] <= OFF_1_source5 + alpha*T_period[1] +ceil(L[1] - maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync));
}
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[3]-1) {
OFF_1_switch2 + alpha*T_period[1] <= OFF_3_switch1 + beta*T_period[3] +ceil(L[3] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_3_switch2 + beta*T_period[3] <= OFF_1_source5 + alpha*T_period[1] +ceil(L[1] - maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync));
}
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[4]-1) {
OFF_1_switch2 + alpha*T_period[1] <= OFF_4_switch1 + beta*T_period[4] +ceil(L[4] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_4_switch2 + beta*T_period[4] <= OFF_1_source5 + alpha*T_period[1] +ceil(L[1] - maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync));
}
forall(alpha in 0..repetitions[1]-1, beta in 0..repetitions[5]-1) {
OFF_1_switch2 + alpha*T_period[1] <= OFF_5_switch1 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_5_switch2 + beta*T_period[5] <= OFF_1_source5 + alpha*T_period[1] +ceil(L[1] - maxl(0, (p_switch2 - p_source5)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_source5)*T_sync));
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[3]-1) {
OFF_2_switch2 + alpha*T_period[2] <= OFF_3_switch1 + beta*T_period[3] +ceil(L[3] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_3_switch2 + beta*T_period[3] <= OFF_2_switch1 + alpha*T_period[2] +ceil(L[2] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync));
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[4]-1) {
OFF_2_switch2 + alpha*T_period[2] <= OFF_4_switch1 + beta*T_period[4] +ceil(L[4] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_4_switch2 + beta*T_period[4] <= OFF_2_switch1 + alpha*T_period[2] +ceil(L[2] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync));
}
forall(alpha in 0..repetitions[2]-1, beta in 0..repetitions[5]-1) {
OFF_2_switch2 + alpha*T_period[2] <= OFF_5_switch1 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_5_switch2 + beta*T_period[5] <= OFF_2_switch1 + alpha*T_period[2] +ceil(L[2] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync));
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
OFF_3_switch2 + alpha*T_period[3] <= OFF_4_switch1 + beta*T_period[4] +ceil(L[4] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_4_switch2 + beta*T_period[4] <= OFF_3_switch1 + alpha*T_period[3] +ceil(L[3] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync));
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
OFF_3_switch2 + alpha*T_period[3] <= OFF_5_switch1 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_5_switch2 + beta*T_period[5] <= OFF_3_switch1 + alpha*T_period[3] +ceil(L[3] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync));
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch2 + alpha*T_period[4] <= OFF_5_switch1 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync))||
OFF_5_switch2 + beta*T_period[5] <= OFF_4_switch1 + alpha*T_period[4] +ceil(L[4] - maxl(0, (p_switch2 - p_switch1)*T_sync, (p_switch2 - p_GM1)*T_sync, (p_GM1 - p_switch1)*T_sync));
}

// Port of switch3 towards switch4 
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[4]-1) {
OFF_3_switch3 + alpha*T_period[3] <= OFF_4_switch2 + beta*T_period[4] +ceil(L[4] - maxl(0, (p_switch3 - p_switch2)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_switch2)*T_sync))||
OFF_4_switch3 + beta*T_period[4] <= OFF_3_switch2 + alpha*T_period[3] +ceil(L[3] - maxl(0, (p_switch3 - p_switch2)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_switch2)*T_sync));
}
forall(alpha in 0..repetitions[3]-1, beta in 0..repetitions[5]-1) {
OFF_3_switch3 + alpha*T_period[3] <= OFF_5_switch2 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch3 - p_switch2)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_switch2)*T_sync))||
OFF_5_switch3 + beta*T_period[5] <= OFF_3_switch2 + alpha*T_period[3] +ceil(L[3] - maxl(0, (p_switch3 - p_switch2)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_switch2)*T_sync));
}
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch3 + alpha*T_period[4] <= OFF_5_switch2 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch3 - p_switch2)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_switch2)*T_sync))||
OFF_5_switch3 + beta*T_period[5] <= OFF_4_switch2 + alpha*T_period[4] +ceil(L[4] - maxl(0, (p_switch3 - p_switch2)*T_sync, (p_switch3 - p_GM1)*T_sync, (p_GM1 - p_switch2)*T_sync));
}

// Port of switch4 towards switch5 
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch4 + alpha*T_period[4] <= OFF_5_switch3 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch4 - p_switch3)*T_sync, (p_switch4 - p_GM1)*T_sync, (p_GM1 - p_switch3)*T_sync))||
OFF_5_switch4 + beta*T_period[5] <= OFF_4_switch3 + alpha*T_period[4] +ceil(L[4] - maxl(0, (p_switch4 - p_switch3)*T_sync, (p_switch4 - p_GM1)*T_sync, (p_GM1 - p_switch3)*T_sync));
}

// Port of switch5 towards sink3 
forall(alpha in 0..repetitions[4]-1, beta in 0..repetitions[5]-1) {
OFF_4_switch5 + alpha*T_period[4] <= OFF_5_switch4 + beta*T_period[5] +ceil(L[5] - maxl(0, (p_switch5 - p_switch4)*T_sync, (p_switch5 - p_GM1)*T_sync, (p_GM1 - p_switch4)*T_sync))||
OFF_5_switch5 + beta*T_period[5] <= OFF_4_switch4 + alpha*T_period[4] +ceil(L[4] - maxl(0, (p_switch5 - p_switch4)*T_sync, (p_switch5 - p_GM1)*T_sync, (p_GM1 - p_switch4)*T_sync));
}


 // The e2e latency: lamda = last_offset.OFF + trans_delay(switch_ID) - first_offset.OFF
lambda_1 == OFF_1_switch3  - OFF_1_source5 + (trans_delay[1] + prop_delay- minl(0,(p_switch3 - p_source5), (p_GM1 - p_source5), (p_switch3 - p_GM1))*T_sync);
lambda_2 == OFF_2_switch3  - OFF_2_source2 + (trans_delay[2] + prop_delay- minl(0,(p_switch3 - p_source2), (p_GM1 - p_source2), (p_switch3 - p_GM1))*T_sync);
lambda_3 == OFF_3_switch4  - OFF_3_source4 + (trans_delay[3] + prop_delay- minl(0,(p_switch4 - p_source4), (p_GM1 - p_source4), (p_switch4 - p_GM1))*T_sync);
lambda_4 == OFF_4_switch5  - OFF_4_source1 + (trans_delay[4] + prop_delay- minl(0,(p_switch5 - p_source1), (p_GM1 - p_source1), (p_switch5 - p_GM1))*T_sync);
lambda_5 == OFF_5_switch5  - OFF_5_source3 + (trans_delay[5] + prop_delay- minl(0,(p_switch5 - p_source3), (p_GM1 - p_source3), (p_switch5 - p_GM1))*T_sync);

// The e2e latency boundaries
min_e2e[1] == lambda_1 <= deadline[1];
min_e2e[2] == lambda_2 <= deadline[2];
min_e2e[3] == lambda_3 <= deadline[3];
min_e2e[4] == lambda_4 <= deadline[4];
min_e2e[5] == lambda_5 <= deadline[5];
}

// Print the decision variables and output as txt file
execute {
var solFile = new IloOplOutputFile("output_CPLEX_solution_NCA.txt");

solFile.writeln("OFF_1_source5 = " + OFF_1_source5 + ";");
solFile.writeln("OFF_1_switch2 = " + OFF_1_switch2 + ";");
solFile.writeln("OFF_1_switch3 = " + OFF_1_switch3 + ";");
solFile.writeln("OFF_2_source2 = " + OFF_2_source2 + ";");
solFile.writeln("OFF_2_switch1 = " + OFF_2_switch1 + ";");
solFile.writeln("OFF_2_switch2 = " + OFF_2_switch2 + ";");
solFile.writeln("OFF_2_switch3 = " + OFF_2_switch3 + ";");
solFile.writeln("OFF_3_source4 = " + OFF_3_source4 + ";");
solFile.writeln("OFF_3_switch1 = " + OFF_3_switch1 + ";");
solFile.writeln("OFF_3_switch2 = " + OFF_3_switch2 + ";");
solFile.writeln("OFF_3_switch3 = " + OFF_3_switch3 + ";");
solFile.writeln("OFF_3_switch4 = " + OFF_3_switch4 + ";");
solFile.writeln("OFF_4_source1 = " + OFF_4_source1 + ";");
solFile.writeln("OFF_4_switch1 = " + OFF_4_switch1 + ";");
solFile.writeln("OFF_4_switch2 = " + OFF_4_switch2 + ";");
solFile.writeln("OFF_4_switch3 = " + OFF_4_switch3 + ";");
solFile.writeln("OFF_4_switch4 = " + OFF_4_switch4 + ";");
solFile.writeln("OFF_4_switch5 = " + OFF_4_switch5 + ";");
solFile.writeln("OFF_5_source3 = " + OFF_5_source3 + ";");
solFile.writeln("OFF_5_switch1 = " + OFF_5_switch1 + ";");
solFile.writeln("OFF_5_switch2 = " + OFF_5_switch2 + ";");
solFile.writeln("OFF_5_switch3 = " + OFF_5_switch3 + ";");
solFile.writeln("OFF_5_switch4 = " + OFF_5_switch4 + ";");
solFile.writeln("OFF_5_switch5 = " + OFF_5_switch5 + ";");

solFile.close();
}