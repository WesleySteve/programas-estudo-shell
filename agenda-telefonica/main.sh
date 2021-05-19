#!/usr/bin/env bash


#----------------------- INICIO DO PROGRAMA ----------------------------------#


# verifica se é root
(($UID == 0)) && { printf "Root não!"; exit 1 ; }

#------------------------ VARIAVEIS GLOBAIS ----------------------------------#

#------- CORES  -------------#
fecha="\033[m"

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

EOF

}

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
    
    printf %b "\n${verde}Dados cadastrados com sucesso.${fecha}\n"
    
else
    printf %b "\n${vermelho}Houve algum erro.${fecha}\n"

fi


}

#----------------------- FIM FUNÇÕES -----------------------------------------# 

#--------------------- MENU PRINCIPAL ----------------------------------------#

# verificando qual parâmetro foi passado.

case "$1" in
    -h|--help) _AJUDA               ;; # chama func ajuda
    -a|--adicionar) _ADICIONAR      ;; # chamada func adicionar
    
    *) printf %b "voce pode conferir toda ajuda utilizando o parametro ${vermelho}-h${fecha} ou ${vermelho}--help${fecha}\n"
        
esac

#-------------------- FIM MENU PRINCIPAL -------------------------------------#


#------------------------ FIM DO PROGRAMA ------------------------------------#

