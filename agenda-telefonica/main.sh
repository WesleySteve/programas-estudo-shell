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

pesquisa=('NOME' 'SOBRENOME' 'DDD' 'TELEFONE' 'SAIR')



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

#------------ AJUDA DO PROGRAMA ---------------------#

function _AJUDA() {

cat << EOF
OPÇÕES DISPONIVEIS:
  -h ou --help        para ajuda
  -c ou --criar       para criar um novo contato
  -p ou --pesquisar   para pesquisar um contato por ID
  -r ou --remover     para remover um contato por ID
  -a ou --atualizar   para atualizar os dados de um contato por ID

EOF

}

#----------- FIM AJUDA DO PROGRAMA -------------------#

#-------------- CRIAR NOVO CONTATO -----------------#

function _CRIAR() {

#------ VARIAVEIS LOCAIS -----------#

local _id=''
local _gravar_dados=''

#------ FIM VARIAVEIS LOCAIS --------#

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
_id=$(wc -l < "${banco_de_dados}")

# enviando para o banco de dados
_gravar_dados="${_id};${dados[1]};${dados[2]};${dados[3]};${dados[4]}"

if echo "${_gravar_dados,,}" >> "${banco_de_dados}"
then
  printf %b "\n${verde}Dados cadastrados com sucesso.${fechar_cor}\n"  
else
  printf %b "\n${vermelho}Houve algum erro.${fechar_cor}\n"
  
fi

}

#---------------- FIM CRIAR CONTATO  --------------------------#

#--------------- PESQUISAR CONTATO -----------------------------#

function _PESQUISAR() {

#-------- VARIAVEIS LOCAIS -------#

local _parametro=''
local _pesqID=''
local _id=''
local _nome=''
local _sobrenome=''
local _ddd=''
local _telefone=''
local _resultado=''

#------- FIM VARIAVEIS LOCAIS -----#

_parametro="$1"

if [[ "${_parametro}" = "-p" ]]
then
  read -p "Digite o ID do Usuario: " _pesqID
  _pesqID="${_pesqID:="-1"}"

elif [[ "${_parametro}" -gt "0" ]]
then
  _pesqID="${_parametro}"
  
fi

if [[ "${_pesqID}" = "-1" ]]
then
  printf %b "\n${vermelho}Usuario não encontrado.${fechar_cor}\n"
  exit 1
else
  if grep -q "^${_pesqID}" "${banco_de_dados}"
  then
    
    _resultado=$(grep "^${_pesqID}" "${banco_de_dados}" )
    
    _id=$(cut -d ';' -f '1' <<< "${_resultado}" )
    _nome=$( cut -d ';' -f '2' <<< "${_resultado}" )
    _sobrenome=$(cut -d ';' -f '3' <<< "${_resultado}" )
    _ddd=$(cut -d ';' -f '4' <<< "${_resultado}"  )
    _telefone=$(cut -d ';' -f '5' <<< "${_resultado}" )
        
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

#----------------- FIM PESQUISA CONTATO -------------------------#

#----------------- REMOVER CONTATO -----------------------------#

function _REMOVER() {

#------------ VARIAVEIS LOCAIS ------------#

local _pesqID=''
local _excluir=''

#----------- FIM VARIAVEIS LOCAIS ----------#

read -p "Digire o ID do Usuario: " _pesqID
_pesqID="${_pesqID:="-1"}"

if [[ "${_pesqID}" = "-1" ]]
then
  printf %b "\n${vermelho}Usuario não encontrado!${fecha_cor}\n"; exit 1 ;
else
  if _PESQUISAR "${_pesqID}"
  then
    
    read -p "Deseja excluir o usuario listado: [S/n] " _excluir
    _excluir="${_excluir:=s}"
    _excluir="${_excluir,,}"
    
    if [[ "${_excluir}" = "s" || "${_excluir}" = "sim" ]]
    then
      # if comando remover o usuario do banco
      # then
        printf %b "${verde}Usuario removido com sucesso!${fechar_cor}\n"
        
      # else
      #   # printf %b "${vermelho}Houve algum erro..${fechar_cor}\n"
      # fi
      
      else
        printf %b "\n${azul}Nada será feito!${fechar_cor}\n"        
      
    fi
    
  fi
  
fi


}

#---------------- FIM REMOVER CONTATO -------------------------#

#------------- ATUALZIAR CONTATO ------------------------#

function _ATUALIZAR() {

#---------- VARIAVEIS LOCAIS -----------#

local _pesqID=''
local _atualizar=''
local _escolha=''

local _nome=''

#---------- FIM VARIAVEIS LOCAIS ------------#

read -p "Digite o ID do usuario: " _pesqID
_pesqID="${_pesqID:="-1"}"

if [[ "${_pesqID}" = "-1" ]]
then
  printf %b "\n${vermelho}Usuario não encontrado!${fechar_cor}\n"; exit 1 ;
else
  if _PESQUISAR "${_pesqID}"
  then
    
    read -p "Deseja alterar os dados deste usuario: [S/n] " _atualizar
    
    _atualizar="${_atualizar:=s}"
    _atualizar="${_atualizar,,}"
    
    if [[ "${_atualizar}" = "s" || "${_atualizar}" = "sim" ]]
    then
      
      # aqui é para selecionar qual campo deseja alterar
      PS3="Escolha qual campo deseja alterar: "
      
      select op in "${pesquisa[@]}"; do
        
        # selecionando uma opção
        _escolha="${op}"
        break
        
      done

      if [[ "${_escolha}" = "NOME" ]]
      then
        read -p "Digite o novo nome: " _nome
        _nome="${_nome:="vazio"}"
        _nome="${_nome,,}"

        if [[ "${_nome}" = "vazio" ]]
        then
          printf %b "\n${vermelho}O nome não pode ser vazio!${fechar_cor}\n"
          exit 1 ;
        else
          printf "\n${verde}Nome atualizado com sucesso${fechar_cor}\n"
        fi
      
      
      fi

      

      
    fi
    
  fi
  
fi


}

#----------- FIM ATUALIZAR CONTATO ------------------------#

#----------------------- FIM FUNÇÕES -----------------------------------------# 

#--------------------- MENU PRINCIPAL ----------------------------------------#

# verificando qual parâmetro foi passado.

case "$1" in
  -h|--help) _AJUDA                 ;; # chama func ajuda
  -c|--criar) _CRIAR                ;; # chamada func adicionar
  -p|--pesquisar) _PESQUISAR  "$1"  ;; # chama func pesquisar 'por id'
  -r|--remover) _REMOVER            ;; # chamada func remover 'por id'
  -a|--atualizar) _ATUALIZAR        ;; # chamada func atualizar 'por id'
  *) _AJUDA                           # chamada func ajuda
        
esac

#-------------------- FIM MENU PRINCIPAL -------------------------------------#

#------------------------------- FIM DO PROGRAMA -----------------------------#

