%comandos de limpeza de tela e memória
clear all;
clc;


%%%%%%%%%%%%%%%%-----ALEATÓRIOS-----%%%%%%%%%%%%%%%

% Ler dados da planilha do Excel
dadosV1 = xlsread('Trabalho 03 - MLP dados.xlsx', 'Sheet3',  'D4:BR4');
dadosV2 = xlsread('Trabalho 03 - MLP dados.xlsx', 'Sheet3',  'D5:BR5');
dadosS = xlsread('Trabalho 03 - MLP dados.xlsx', 'Sheet3',  'D6:BR6');
dados = [dadosV1; dadosV2];

%Entrada
[E, norm_e] = mapminmax(dados);

%Saída
[S, norm_s] = mapminmax(dadosS);

%Pegando as amostras aleatoriamente
numAmostras = size(E, 2); % Obtém o número de colunas em E
indicesAleatorios = randperm(numAmostras);

numAmostrasTreino = round(0.3 * numAmostras);
numAmostrasTeste = numAmostras - numAmostrasTreino;

entradas_treino = E(:, indicesAleatorios(1:numAmostrasTreino));
saidas_treino = S(:, indicesAleatorios(1:numAmostrasTreino));

entradas_teste = E(:, indicesAleatorios(numAmostrasTreino+1:end));
saidas_teste = S(:, indicesAleatorios(numAmostrasTreino+1:end));

num_redes =25;
saida_RNAs = cell(1,num_redes)
saida_RNAs_desnorm = cell(1,num_redes)

for i = 1:num_redes
    %Parâmetros de Treino
    RNA=newff(minmax(entradas_treino), [3 4 1], {'tansig', 'tansig', 'tansig'}, 'trainlm');
    RNA.trainparam.epochs=10000;
    RNA.trainparam.goal=1e-10; %mse
    RNA.trainparam.min_grad=1e-4;
    RNA.trainparam.max_fail=10;
    RNA.divideFcn = 'dividerand'
    
   

    %Execução da Rede
    RNA=train(RNA,entradas_treino,saidas_treino);
    saida_RNAs{i} = RNA(entradas_teste);  
    saida_RNAs_desnorm{i}=mapminmax('reverse',saida_RNAs{i}, norm_s);  
end


saidas_teste_desnorm=mapminmax('reverse',saidas_teste, norm_s); 
vetor_redes = 1:num_redes;

% Calculando o MSE acumulado
mseAcumulado = zeros(1, num_redes);

for k = 1:num_redes
    erros = saida_RNAs_desnorm{k} - saidas_teste_desnorm;
    mseAcumulado(k) = mean(erros.^2);
end

% Calculando o MSE médio acumulado
mseMediaAcumulada = zeros(1, num_redes);

for k = 1:num_redes
    mseMediaAcumulada(k) = mean(mseAcumulado(1:k));
end

% Plotando a evolução do MSE acumulado
figure;
plot(vetor_redes, mseMediaAcumulada, 'k.-', 'MarkerSize', 12);
xlabel('Número da Rede');
ylabel('MSE Acumulado');
title('Evolução do MSE Acumulado(Comitê de Redes Aleatórios)');

%%%%%%%%%%%%%%%%-----SELECIONADOS-----%%%%%%%%%%%%%%%



% Ler dados da planilha do Excel
dadosV1_ii = xlsread('Trabalho 03 - MLP dados - Selecionados.xlsx', 'Sheet3',  'D14:W14');
dadosV2_ii = xlsread('Trabalho 03 - MLP dados - Selecionados.xlsx', 'Sheet3',  'D15:W15');
dadosS_ii = xlsread('Trabalho 03 - MLP dados - Selecionados.xlsx', 'Sheet3',  'D16:W16');
dados_ii = [dadosV1_ii; dadosV2_ii];

dadosV1_teste_ii = xlsread('Trabalho 03 - MLP dados - Selecionados.xlsx', 'Sheet3',  'D18:AX18');
dadosV2_teste_ii = xlsread('Trabalho 03 - MLP dados - Selecionados.xlsx', 'Sheet3',  'D19:AX19');
dadosS_teste_ii = xlsread('Trabalho 03 - MLP dados - Selecionados.xlsx', 'Sheet3',  'D20:AX20');
dados_teste_ii = [dadosV1_teste_ii; dadosV2_teste_ii];


%Entrada
[E_treino_ii, norm_e_ii] = mapminmax(dados_ii);
[E_teste_ii, norm_f_ii] = mapminmax(dados_teste_ii);

%Saída
[S_treino_ii, norm_s_ii] = mapminmax(dadosS_ii);


num_redes_ii =25;
saida_RNAs_ii = cell(1,num_redes_ii)
saida_RNAs_desnorm_ii = cell(1,num_redes_ii)

for i = 1:num_redes_ii
    %Parâmetros de Treino
    RNA_ii=newff(minmax(E_treino_ii), [3 4 1], {'tansig', 'tansig', 'tansig'}, 'trainlm');
    RNA_ii.trainparam.epochs=10000;
    RNA_ii.trainparam.goal=1e-10; %mse
    RNA_ii.trainparam.min_grad=1e-4;
    RNA_ii.trainparam.max_fail=10;
   
   
    %Execução da Rede
    RNA_ii=train(RNA_ii,E_treino_ii,S_treino_ii);
    saida_RNAs_ii{i} = RNA_ii(E_teste_ii);  
    saida_RNAs_desnorm_ii{i}=mapminmax('reverse',saida_RNAs_ii{i}, norm_s_ii);  
end



vetor_redes_ii = 1:num_redes_ii;

% Calculando o MSE acumulado
mseAcumulado_ii = zeros(1, num_redes_ii);

for k = 1:num_redes_ii
    erros_ii = saida_RNAs_desnorm_ii{k} - dadosS_teste_ii;
    mseAcumulado_ii(k) = mean(erros_ii.^2);
end

% Calculando o MSE médio acumulado
mseMediaAcumulada_ii = zeros(1, num_redes_ii);

for k = 1:num_redes_ii
    mseMediaAcumulada_ii(k) = mean(mseAcumulado_ii(1:k));
end

% Plotando a evolução do MSE acumulado
figure(2);
plot(vetor_redes_ii, mseMediaAcumulada_ii, 'k.-','MarkerSize', 12);
xlabel('Número da Rede');
ylabel('MSE Acumulado');
title('Evolução do MSE Acumulado (Comitê de Redes Selecionados)');


%%%%%%%%%%-CALCULANDO MSE ACUMULADO ENTRE OS 2 COMITES%%%%%%%%%%%%
vetor_redes_combinado = 1:(num_redes + num_redes_ii);

% Somando os MSEs acumulados dos dois comitês de rede
mseAcumulado_combinado = [mseAcumulado, mseAcumulado_ii];

% Calculando o MSE médio acumulado combinado
mseMediaAcumulada_combinada = zeros(1, num_redes + num_redes_ii);

for k = 1:(num_redes + num_redes_ii)
    mseMediaAcumulada_combinada(k) = mean(mseAcumulado_combinado(1:k));
end

% Plotando a evolução do MSE acumulado combinado
figure;
plot(vetor_redes_combinado, mseMediaAcumulada_combinada, 'k.-', 'MarkerSize', 12);
xlabel('Número da Rede');
ylabel('MSE Acumulado');
title('Evolução do MSE Acumulado (Comitês de Rede Combinados)');



