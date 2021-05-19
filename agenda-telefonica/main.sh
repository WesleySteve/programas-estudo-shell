#!/usr/bin/env bash


#----------------------- INICIO DO PROGRAMA ----------------------------------#


# verifica se é root
(($UID == 0)) && { printf "Root não!"; exit 1 ; }

#------------------------ VARIAVEIS GLOBAIS ----------------------------------#

#------- CORES  -------------#
fechar_cor="\033[m"

vermelho="\E[31;1m"
verde="\E[32;1m"
azul="E[34;1m"
branco="\E[37;1m"

#------ FIM CORES -----------#

banco_de_dados="banco-agenda-telefone.txt"

campos=("NOME" "SOBRENOME" "DDD" "TELEFONE")



#---------------------- FIM VARIAVEIS GLOBAIS --------------------------------#

#-------------------------- TESTES -------------------------------------------#

# teste se o arquivo existe
[[ ! -e "${banco_de_dados}" ]] && > "${banco_de_dados}"

#--------------------- FIM TESTES --------------------------------------------#

#--------------------------- FUNÇÕES -----------------------------------------#

_AJUDA() {

cat << EOF
OPÇÕES DISPONIVEIS:
    -h ou --help
    -a ou --adicionar
    -p ou --pesquisar

EOF

}

#---- ADICIONAR CONTATO -------#

_ADICIONAR() {

#------ VARIAVEIS LOCAIS -----------#

local _id=""

#------ FIM VARIAVEIS LOCAIS -------#

# verifica o numero de linha no banco de dados
_id=$(($(wc -l < "${banco_de_dados}")))

# atribui os campos de controlee no banco de dados
(($_id == 0)) && { echo "${campos[@]}" | tr ' ' ';' >> "${banco_de_dados}" ;}

i=1

for dados in "${campos[@]}"; do

    while [[ -z "${dados[i]}" ]]; do
        
        read -p "${dados}": dados[$i]
        
    done
    ((i++))
done

# gerando o ID
_id=$(($(wc -l < "${banco_de_dados}")))

# enviando para o banco de dados

if echo "${_id};${dados[1]};${dados[2]};${dados[3]};${dados[4]}" | tr 'A-Z' 'a-z' >> "${banco_de_dados}"; then
    
    printf %b "\n${verde}Dados cadastrados com sucesso.${fechar_cor}\n"
    
else
    printf %b "\n${vermelho}Houve algum erro.${fechar_cor}\n"

fi


}

#----- PESQUISAR CONTATO ---------#

_PESQUISAR() {

#-------- VARIAVEIS LOCAIS -------#

local _pesqID=""
local _id=""
local _nome=""
local _sobrenome=""
local _ddd=""
local _telefone=""

#------- FIM VARIAVEIS LOCAIS -----#

read -p "Digite o ID do Usuario: " _pesqID

if [[ -z "${_pesqID}" ]]; then
    
    printf %b "\n${vermelho}Usuario não encontrado.${fechar_cor}\n"; exit 1 ;
    

fi



}

#----------------------- FIM FUNÇÕES -----------------------------------------# 

#--------------------- MENU PRINCIPAL ----------------------------------------#

# verificando qual parâmetro foi passado.

case "$1" in
    -h|--help) _AJUDA               ;; # chama func ajuda
    -a|--adicionar) _ADICIONAR      ;; # chamada func adicionar
    -p|--pesquisar) _PESQUISAR      ;; # chama func pesquisar 'por id'
    
    *) _AJUDA                           # chamada func ajuda
        
esac

#-------------------- FIM MENU PRINCIPAL -------------------------------------#


#------------------------ FIM DO PROGRAMA ------------------------------------#

