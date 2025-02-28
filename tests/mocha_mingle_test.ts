import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create a new recipe",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'create-recipe', [
        types.ascii("Cold Brew"),
        types.ascii("Step 1: Grind coffee..."),
        types.uint(3)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    const recipe = chain.callReadOnlyFn(
      'mocha-mingle',
      'get-recipe',
      [types.uint(1)],
      deployer.address
    );
    
    recipe.result.expectOk();
  }
});

Clarinet.test({
  name: "Can rate a recipe",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    
    // First create a recipe
    let block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'create-recipe', [
        types.ascii("Cold Brew"),
        types.ascii("Step 1: Grind coffee..."),
        types.uint(3)
      ], deployer.address)
    ]);
    
    // Then rate it
    block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'rate-recipe', [
        types.uint(1),
        types.uint(5)
      ], user1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify rating
    const rating = chain.callReadOnlyFn(
      'mocha-mingle',
      'get-rating',
      [types.principal(user1.address), types.uint(1)],
      user1.address
    );
    
    rating.result.expectOk().expectUint(5);
  }
});

Clarinet.test({
  name: "Can add a comment to a recipe",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    
    // Create recipe
    let block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'create-recipe', [
        types.ascii("Cold Brew"),
        types.ascii("Step 1: Grind coffee..."),
        types.uint(3)
      ], deployer.address)
    ]);
    
    // Add comment
    block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'add-comment', [
        types.uint(1),
        types.ascii("Great recipe!")
      ], user1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    // Verify comment
    const comment = chain.callReadOnlyFn(
      'mocha-mingle',
      'get-comment',
      [types.uint(1)],
      user1.address
    );
    
    comment.result.expectOk();
  }
});
