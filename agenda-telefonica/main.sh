#!/usr/bin/env bash


#----------------------- INICIO DO PROGRAMA ----------------------------------#


# verifica se é root
(($UID == 0)) && { printf "Root não!"; exit 1 ; }

#------------------------ VARIAVEIS GLOBAIS ----------------------------------#

#------- CORES  -------------#
fechar_cor="\033[m"

vermelho="\033[31;1m"
verde="\033[32;1m"
azul="\033[34;1m"
branco="\033[37;1m"

#------ FIM CORES -----------#

banco_de_dados="banco-agenda-telefone.txt"

campos=('NOME' 'SOBRENOME' 'DDD' 'TELEFONE')



#---------------------- FIM VARIAVEIS GLOBAIS --------------------------------#

#-------------------------- TESTES -------------------------------------------#

# teste se o arquivo existe
[[ ! -e "${banco_de_dados}" ]] && > "${banco_de_dados}"

#--------------------- FIM TESTES --------------------------------------------#

#--------------------------- FUNÇÕES -----------------------------------------#

#------------------------ DEBUGGER -------------------------------------#

function debug_ativado() {

if [[ "$DEBUG" -eq "0" ]]
then
  set -x
  printf %b "${vermelho}+++++++++ DEBUG ATIVADO ++++++++++++++"
fi

}

function debug_desativado() {

if [[ "$DEBUG" -eq "1" ]]
then
  set +x
  printf %b "-------- DEBUG DESATIVADO ---------${fecha_cor}"    
fi

}

#----------------------- FIM DEBUGGER -----------------------------------#

#------------ AJUDA DO PROGRAMA ---------------------------------------#

function _AJUDA() {

cat << EOF
OPÇÕES DISPONIVEIS:
  -h ou --help
  -c ou --criar
  -p ou --pesquisar

EOF

}

#---- ADICIONAR CONTATO -------#

function _CRIAR() {

#------ VARIAVEIS LOCAIS -----------#

local _id=''
local _gravar_dados=''

#------ FIM VARIAVEIS LOCAIS -------#

# verifica o numero de linha no banco de dados
_id=$(wc -l < "${banco_de_dados}")

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

if echo "${_id};${dados[1]};${dados[2]};${dados[3]};${dados[4]}" | tr 'A-Z' 'a-z' >> "${banco_de_dados}"
then
  printf %b "\n${verde}Dados cadastrados com sucesso.${fechar_cor}\n"  
else
  printf %b "\n${vermelho}Houve algum erro.${fechar_cor}\n"
  
fi

}

#----- PESQUISAR CONTATO ---------#

function _PESQUISAR() {

#-------- VARIAVEIS LOCAIS -------#

local _pesqID=''
local _id=''
local _nome=''
local _sobrenome=''
local _ddd=''
local _telefone=''

#------- FIM VARIAVEIS LOCAIS -----#

read -p "Digite o ID do Usuario: " _pesqID

if [[ -z "${_pesqID}" ]]
then
  printf %b "\n${vermelho}Usuario não encontrado.${fechar_cor}\n"; exit 1 ;  
else
  if grep -q "^${_pesqID}" "${banco_de_dados}"
  then
    
    _id=$(grep "^${_pesqID}" "${banco_de_dados}" | cut -d ';' -f '1' )
    _nome=$(grep "^${_pesqID}" "${banco_de_dados}" | cut -d ';' -f '2' )
    _sobrenome=$(grep "^${_pesqID}" "${banco_de_dados}" | cut -d ';' -f '3' )
    _ddd=$(grep "^${_pesqID}" "${banco_de_dados}" | cut -d ';' -f '4' )
    _telefone=$(grep "^${_pesqID}" "${banco_de_dados}" | cut -d ';' -f '5' )
        
    else
      printf %b "\n${vermelho}Usuario não encontrado.${fechar_cor}\n"; exit 1 ;
       
    fi
fi

cat << RESULTADO
==============================================================
ID USUARIO: ${_id}
NOME:       ${_nome}
SOBRENOME:  ${_sobrenome}
TELEFONE COM DDD: (${_ddd}) ${_telefone}
==============================================================
RESULTADO

}

#----------------------- FIM FUNÇÕES -----------------------------------------# 

#--------------------- MENU PRINCIPAL ----------------------------------------#

# verificando qual parâmetro foi passado.

case "$1" in
  -h|--help) _AJUDA               ;; # chama func ajuda
  -c|--criar) _CRIAR              ;; # chamada func adicionar
  -p|--pesquisar) _PESQUISAR      ;; # chama func pesquisar 'por id'
    
  *) _AJUDA                           # chamada func ajuda
        
esac

#-------------------- FIM MENU PRINCIPAL -------------------------------------#

#------------------------------- FIM DO PROGRAMA -----------------------------#

