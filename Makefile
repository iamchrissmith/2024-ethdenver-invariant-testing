build             :; forge build
clean             :; forge clean
.PHONY: test
test			  :; forge test --nmt="invariant"
invariant		  :; forge test --mt="invariant" -vvvv
