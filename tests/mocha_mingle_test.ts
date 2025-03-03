// [Previous test content remains unchanged, new tests added below]

Clarinet.test({
  name: "Can update an existing recipe",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    // First create a recipe
    let block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'create-recipe', [
        types.ascii("Cold Brew"),
        types.ascii("Original content"),
        types.uint(3)
      ], deployer.address)
    ]);
    
    // Update the recipe
    block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'update-recipe', [
        types.uint(1),
        types.ascii("Updated Cold Brew"),
        types.ascii("Updated content"),
        types.uint(4)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});

Clarinet.test({
  name: "Can delete a recipe",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    // Create and then delete a recipe
    let block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'create-recipe', [
        types.ascii("Cold Brew"),
        types.ascii("Content"),
        types.uint(3)
      ], deployer.address)
    ]);
    
    block = chain.mineBlock([
      Tx.contractCall('mocha-mingle', 'delete-recipe', [
        types.uint(1)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});
