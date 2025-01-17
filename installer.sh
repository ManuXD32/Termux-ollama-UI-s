#!/data/data/com.termux/files/usr/bin/bash

# Function to display the menu and get user choices
display_menu() {
    echo "Select utilities to install (separate choices with spaces):"
    echo "1. Ollama"
    echo "2. Open WebUI"
    echo "3. Oobabooga"
    echo "4. Big-AGI"
    echo "5. fastsdcpu (stable diffusion cpu)"
    echo "6. llama.cpp"
    echo "7. exo"
    echo "8. automatic 1111 (after installing the server will start automatically, stop it with ctrl + c)"
    echo "9. Exit"
}

# Display the menu
clear
display_menu

# Get user choices
read -p "Enter your choices: " choices

# Track if UI setup is done
ui_setup_done=false

# Process each choice
for choice in $choices; do
    apt update && apt install proot-distro -y
    case $choice in
        1)
            echo "Installing Ollama..."
            pd install --override-alias ollama ubuntu
            pd login ollama -- bash -c "apt update && apt upgrade -y && apt install ca-certificates -y && update-ca-certificates -v && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure ca-certificates && curl -fsSL https://ollama.com/install.sh | sh"
            ;;
        2)
            if [ "$ui_setup_done" = false ]; then
                echo "Setting up UI environment..."
                pd install --override-alias ui ubuntu
                ui_setup_done=true
            fi
            echo "Setting up Open WebUI..."
            pd login ui -- bash -c "apt update && apt upgrade -y && curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh && bash /root/Miniconda3-latest-Linux-aarch64.sh -b -p /root/miniconda3" 
	    pd login ui -- bash -c "/root/miniconda3/bin/conda create -n webui python=3.11 -y && /root/miniconda3/envs/webui/bin/pip install open-webui && apt install libsndfile1 libsndfile1-dev -y"
            ;;
        3)
            if [ "$ui_setup_done" = false ]; then
                echo "Setting up UI environment..."
                pd install --override-alias ui ubuntu
                ui_setup_done=true
            fi
            echo "Installing Oobabooga..."
            pd login ui -- bash -c "apt update && apt upgrade -y && curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh && bash /root/Miniconda3-latest-Linux-aarch64.sh -b -p /root/miniconda3" 
	    pd login ui -- bash -c "/root/miniconda3/bin/conda create -n textgen python=3.11 -y && /root/miniconda3/envs/textgen/bin/pip3 install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cpu && apt install git -y && git clone https://github.com/oobabooga/text-generation-webui && cd text-generation-webui && /root/miniconda3/envs/textgen/bin/pip3 install -r requirements_cpu_only_noavx2.txt"
            ;;
        4)
            if [ "$ui_setup_done" = false ]; then
                echo "Setting up UI environment..."
                pd install --override-alias ui ubuntu
                ui_setup_done=true
            fi
            echo "Installing Big-AGI..."
            pd login ui -- bash -c "apt install -y ca-certificates curl gnupg git && mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main' | tee /etc/apt/sources.list.d/nodesource.list && apt update && apt install nodejs -y"
            pd login ui -- bash -c "git clone --branch v2-dev https://github.com/enricoros/big-AGI.git && cd big-AGI && npm install -g npm@11.0.0 && npm install && npm run build"
            ;;
	5)
            if [ "$ui_setup_done" = false ]; then
                echo "Setting up UI environment..."
                pd install --override-alias ui ubuntu
                ui_setup_done=true
            fi
            echo "Installing fastsdcpu..."
	    pd login ui -- bash -c "apt update && apt upgrade -y && curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh && bash /root/Miniconda3-latest-Linux-aarch64.sh -b -p /root/miniconda3"
	    pd login ui -- bash -c "/root/miniconda3/bin/conda create -n fastsdcpu python=3.11 -y && apt update && apt upgrade -y && apt install ffmpeg git -y && git clone https://github.com/rupeshs/fastsdcpu.git"
	    pd login ui -- bash -c "sed -i 's|PYTHON_COMMAND=\"python3\"|PYTHON_COMMAND=\"/root/miniconda3/envs/fastsdcpu/bin/python3\"|g' /root/fastsdcpu/install.sh"
	    pd login ui -- bash -c "sed -i 's|PYTHON_COMMAND=\"python\"|PYTHON_COMMAND=\"/root/miniconda3/envs/fastsdcpu/bin/python3\"|g' /root/fastsdcpu/install.sh"
	    pd login ui -- bash -c "sed -i '/\$PYTHON_COMMAND -m venv \"\$BASEDIR\/env\"/,+2d' /root/fastsdcpu/install.sh"
	    pd login ui -- bash -c "sed -i 's|\\bpip\\b|/root/miniconda3/envs/fastsdcpu/bin/pip|g' /root/fastsdcpu/install.sh"
	    pd login ui -- bash -c "sed -i '/source \"\\\$BASEDIR\\/env\\/bin\\/activate\"/d' /root/fastsdcpu/start-webui.sh"
            pd login ui -- bash -c "sed -i 's|PYTHON_COMMAND=\"python3\"|PYTHON_COMMAND=\"/root/miniconda3/envs/fastsdcpu/bin/python3\"|g' /root/fastsdcpu/start-webui.sh"
            pd login ui -- bash -c "sed -i 's|PYTHON_COMMAND=\"python\"|PYTHON_COMMAND=\"/root/miniconda3/envs/fastsdcpu/bin/python3\"|g' /root/fastsdcpu/start-webui.sh"
 	    pd login ui -- bash -c "cd fastsdcpu && chmod +x install.sh && ./install.sh --disable-gui"
	    ;;
        6)
            echo "Building llamacpp on termux"
            apt update && apt install cmake git -y
	    cd ~ && git clone https://github.com/ggerganov/llama.cpp
            cd llama.cpp && mkdir models2 && cmake -B build && cmake --build build --config Release -j 8
	    cd ~
            ;;
        7)
            pd install --override-alias exo ubuntu
            echo "Installing exo..."
            pd login exo -- bash -c "apt update && apt upgrade -y && apt install libglib2.0-0 libgl1 python3 python3-pip pipenv -y && git clone https://github.com/exo-explore/exo.git && cd exo && pipenv lock && pipenv install . torch flax"
            ;;
	8)
            if [ "$ui_setup_done" = false ]; then
                echo "Setting up UI environment..."
                pd install --override-alias ui ubuntu
                ui_setup_done=true
            fi
	    echo "Installing automatic 1111..."
            pd login ui -- bash -c "apt update && apt upgrade -y && useradd -m -p '' auto --shell /bin/bash"
            pd login --user auto ui -- bash -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git"
            pd login ui -- bash -c "apt install software-properties-common -y && yes | add-apt-repository ppa:deadsnakes/ppa && apt update && apt install wget git python3.11 python3.11-venv libgl1 libglib2.0-0 gcc python3.11-dev -y"
            pd login ui -- bash -c "sed -i 's/#python_cmd=\"python3\"/python_cmd=\"python3.11\"/; s/#export COMMANDLINE_ARGS=\"\"/export COMMANDLINE_ARGS=\"--port 7865 --api --use-cpu all --precision full --no-half --skip-torch-cuda-test --skip-load-model-at-start\"/' /home/auto/stable-diffusion-webui/webui-user.sh"
            pd login --user auto ui -- bash -c "cd stable-diffusion-webui && chmod +x webui.sh && ./webui.sh"
	    ;;
        9)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice: $choice"
            ;;
    esac
done

echo "Installation completed."
