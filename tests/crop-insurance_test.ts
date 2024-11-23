import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensures farmers can join pool with valid premium",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const farmer = accounts.get('wallet_1')!;
        let block = chain.mineBlock([
            Tx.contractCall('crop-insurance', 'join-pool', [
                types.uint(200)
            ], farmer.address)
        ]);
        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Ensures claims can be processed",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const farmer = accounts.get('wallet_1')!;
        
        // First join pool
        let block1 = chain.mineBlock([
            Tx.contractCall('crop-insurance', 'join-pool', [
                types.uint(200)
            ], farmer.address)
        ]);
        
        // Then claim
        let block2 = chain.mineBlock([
            Tx.contractCall('crop-insurance', 'claim-insurance', [], 
            farmer.address)
        ]);
        
        block2.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Prevents double claims",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const farmer = accounts.get('wallet_1')!;
        
        // Join and first claim
        let block1 = chain.mineBlock([
            Tx.contractCall('crop-insurance', 'join-pool', [
                types.uint(200)
            ], farmer.address),
            Tx.contractCall('crop-insurance', 'claim-insurance', [], 
            farmer.address)
        ]);
        
        // Try second claim
        let block2 = chain.mineBlock([
            Tx.contractCall('crop-insurance', 'claim-insurance', [], 
            farmer.address)
        ]);
        
        block2.receipts[0].result.expectErr(types.uint(104)); // err-already-claimed
    },
});
