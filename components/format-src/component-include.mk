format-src:
	astyle -n \
		--indent=spaces=2 \
		--style=attach \
		--pad-oper \
		--pad-header \
		--align-pointer=type \
		--align-reference=type \
		--add-brackets \
		$(PROJECT_PATH)/main/*
