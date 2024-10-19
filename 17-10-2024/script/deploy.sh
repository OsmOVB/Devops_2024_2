#!/bin/bash

# Definir variáveis
REPO_URL="git@github.com:OsmOVB/Devops_2024_2.git" # URL do repositório
PROJECT_DIR="/caminho/para/diretório/projeto"  # Caminho para o diretório do projeto
VENV_DIR="$PROJECT_DIR/venv"
PYTHON_EXEC="$VENV_DIR/bin/python3"
MAIN_PY="$PROJECT_DIR/main.py"
PORT=5000  # Porta em que a aplicação Flask está rodando
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"  # Caminho para a chave SSH
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"

# Função para configurar e verificar SSH
setup_ssh() {
    # Verificar se a chave SSH já existe
    if [ ! -f "$SSH_KEY_PATH" ]; then
        echo "Chave SSH não encontrada. Gerando uma nova chave SSH..."
        ssh-keygen -t ed25519 -C "osmar.borges@grupointegrado.br" -f "$SSH_KEY_PATH" -N ""
        echo "Chave SSH gerada com sucesso."
    else
        echo "Chave SSH já existe."
    fi

    # Iniciar o ssh-agent e adicionar a chave SSH
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_PATH"

    # Exibir a chave pública e instruir o usuário a adicioná-la ao GitHub
    echo "A chave pública SSH é:"
    cat "$SSH_KEY_PATH.pub"
    echo "Adicione esta chave ao seu GitHub em https://github.com/settings/keys."
    read -p "Pressione Enter após adicionar a chave ao GitHub."
}

# Função para verificar e instalar o python3-venv, se necessário
install_venv() {
    if ! dpkg -s python3-venv >/dev/null 2>&1; then
        echo "Instalando python3-venv..."
        sudo apt-get update
        sudo apt-get install -y python3-venv
    else
        echo "python3-venv já está instalado."
    fi
}

# Função para matar o processo rodando na porta 5000
kill_process() {
    PID=$(ss -ltnp | grep :$PORT | awk '{print $6}' | cut -d',' -f2 | cut -d'=' -f2)
    if [ -n "$PID" ]; then
        echo "Matando o processo (PID: $PID)..."
        kill -9 $PID
    else
        echo "Nenhum processo rodando na porta $PORT."
    fi
}

# Remover arquivos antigos
cleanup() {
    echo "Removendo arquivos antigos..."
    if [ -d "$PROJECT_DIR" ]; then
        rm -rf $PROJECT_DIR
    fi
}

# Clonar o repositório do GitHub
clone_repo() {
    echo "Clonando o repositório..."
    git clone $REPO_URL $PROJECT_DIR
}

# Criar o arquivo requirements.txt se ele não existir
create_requirements() {
    if [ ! -f "$REQUIREMENTS_FILE" ]; then
        echo "Criando o arquivo requirements.txt..."
        cat <<EOL > "$REQUIREMENTS_FILE"
Flask
flask-cors
EOL
    fi
}

# Criar ambiente virtual e instalar dependências
setup_environment() {
    echo "Criando ambiente virtual..."
    python3 -m venv $VENV_DIR
    if [ -f "$VENV_DIR/bin/activate" ]; then
        source $VENV_DIR/bin/activate
        create_requirements  # Certificar que o arquivo requirements.txt existe
        echo "Instalando dependências..."
        pip install -r $REQUIREMENTS_FILE || echo "Nenhum arquivo requirements.txt encontrado"
    else
        echo "Erro ao criar ambiente virtual."
    fi
}

# Iniciar a aplicação
start_application() {
    echo "Iniciando a aplicação Flask..."
    nohup $PYTHON_EXEC $MAIN_PY > /dev/null 2>&1 &
    echo "Aplicação iniciada."
    echo "A aplicação Flask está rodando em: http://127.0.0.1:$PORT"
}

# Executar as funções
setup_ssh  # Verificar e configurar SSH
install_venv  # Instalar o python3-venv, se necessário
kill_process  # Matar o processo na porta 5000, se existir
cleanup  # Limpar o diretório do projeto
clone_repo  # Clonar o repositório do GitHub
setup_environment  # Criar ambiente virtual e instalar dependências
start_application  # Iniciar a aplicação Flask
