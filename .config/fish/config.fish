if status is-interactive
	clear && neofetch
    # Commands to run in interactive sessions can go here
	 # set -Ux PATH $HOME/.cargo/bin $PATH
	 # Cargo binaries
set -gx PATH $HOME/.cargo/bin $PATH
end
