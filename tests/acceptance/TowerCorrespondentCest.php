<?php


class TowerCorrespondentCest
{

    public function _before(AcceptanceTester $I)
    {
         $I->login($I, 'towercorrespondent');
    }

    public function canOnlySeeOwnTowerOnDashboard(AcceptanceTester $I)
    {
	$I->amOnPage('/index.php/test-dashboard');
        $I->comment('I only see Lindfield, All Saints');
	$I->see('Lindfield, All Saints', '.members-without-invoice');
	$I->dontSee('Lindfield, All Saints', '.invoices-to-be-paid');
	$I->dontSee('Aldingbourne');
    }

    // tests
    public function TowerCorrespondentCanCreateInvoice(AcceptanceTester $I)
    {
	$I->amOnPage('/index.php/test-dashboard');
        $I->comment('I See Lindfield, All Saints');
	$I->see('Lindfield, All Saints');
        $I->comment('I click Login button');
	$I->amOnPage('/index.php/test-dashboard?view=invoice&layout=create&list_view=invoice&towerId=82');
        $I->comment('I see correct total of 72.00');
        $I->see('72.00');
	$I->click(['class' => 'btn-create-invoice']);
        $I->see('Invoice created successfully');
	$I->dontSee('Lindfield, All Saints', '.members-without-invoice');
	$I->see('Lindfield, All Saints', '.invoices-to-be-paid');
	$I->amOnPage('/index.php/component/memberdatabase/?view=invoices');
	$I->see('Lindfield, All Saints');
	$I->amOnPage('/index.php/component/memberdatabase/?view=invoice&layout=edit&id=11');
	//$I->click('Lindfield/10');
	$I->see('Member Database - Invoice Details');
	
	// Weak as will return true if element exists in drop-down
	$I->see('Lindfield, All Saints');
    }

    public function canOnlySeeMinimalMemberAttributes(AcceptanceTester $I)
    {
	$I->amGoingTo('check that I can only see minimal attributes of a member');
	$I->amOnPage('/index.php/component/memberdatabase/?view=members');
	$I->see('Spencer, Jonathan');
	$I->dontSee('Abbott, Deborah');
	$I->click('Spencer, Jonathan');
	$I->see('Lindfield');
	$I->see('16-70');
	$I->dontSee('Telephone Number');
	$I->dontSee('Address 1');
    }

}
