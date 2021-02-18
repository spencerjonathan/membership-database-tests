<?php


class MembershipCoordinatorCest
{

    public function _before(AcceptanceTester $I)
    {
         $I->login($I, 'membershipcoordinator');
    }

    public function canOnlySeeOwnTowerOnDashboard(AcceptanceTester $I)
    {
	$I->amOnPage('/index.php?option=com_memberdatabase&view=memberdatabase');
        $I->comment('I see all towers');
	$I->see('Aldingbourne', '.members-without-invoice');
	$I->see('Warnham, St Margaret', '.members-without-invoice');
	$I->dontSee('Warnham, St Margaret', '.invoices-to-be-paid');
    }

    // tests
    public function canCreateInvoice(AcceptanceTester $I)
    {
	$I->amOnPage('/index.php?option=com_memberdatabase&view=memberdatabase');
    $I->comment('I See Warnham, St Margaret');
	$I->see('Warnham, St Margaret', '.members-without-invoice');
	//$I->amOnPage('/index.php?option=com_memberdatabase&view=invoice&layout=create&list_view=invoice&towerId=138');
	$I->amOnPage('/index.php?option=com_memberdatabase&view=invoice&layout=create&towerId=138');
    $I->comment('I see correct total of 132.00');
    $I->see('132.00');
    $I->comment('I see the Email Invoice button');
    $I->see('Email Invoice');
	$I->click(['class' => 'btn-create-invoice']);
    $I->see('Invoice created successfully');
	$I->dontSee('Warnham, St Margaret', '.members-without-invoice');
	$I->see('Warnham, St Margaret', '.invoices-to-be-paid');
	$I->amOnPage('/index.php?option=com_memberdatabase&view=invoices');
	$I->see('Warnham, St Margaret');

	// Check that the invoice exists
	$I->amOnPage('/index.php?option=com_memberdatabase&view=invoice&layout=edit&id=1');
	//$I->click('Lindfield/10');
	$I->see('Member Database - Invoice Details');
	$I->see('Warnham, St Margaret');

	// Mark the invoice as paid
	$I->fillField('jform[paid_date]', '2018-01-15');
	$I->selectOption('jform[paid]', '1');
	$I->selectOption('jform[payment_method]', 'Cheque');
	$I->fillField('jform[payment_reference]', 'Cheque No: 123456');
	//$I->click(['name' => 'save_button']);
	$I->click(['class' => 'btn-save-invoice']);

        $I->see('Item saved');
        $I->see('Paid');
	
    }

    public function canSeeAllMemberAttributes(AcceptanceTester $I)
    {
	$I->amGoingTo('check that I can see all attributes of a member');
	$I->amOnPage('/index.php/component/memberdatabase/?view=members');
	$I->see('Abbott, Deborah');
	$I->click('Abbott, Deborah');
	$I->see('Sedlescombe');
	$I->see('Telephone Number');
	$I->see('Address 1');
	$I->see('Membership Form Rec\'d');
	$I->see('Notes');
    }

    public function canSeeAMembersInvoices(AcceptanceTester $I)
    {
	$I->amGoingTo('check that I can only see minimal attributes of a member');
	$I->amOnPage('/index.php/component/memberdatabase/?view=member&layout=edit&id=901');
	//$I->see('Invoices');
	$I->see('Warnham', '.invoice-list');
	$I->see('£132.00');
	$I->dontSee('Lindfield', '.invoice-list');
    }

    public function canOnlySeeActiveTowersOnAnnualReport(AcceptanceTester $I)
    {
	$I->amOnPage('/index.php/component/memberdatabase/?view=annualreport');
        $I->comment('I see active towers but not inactive');
	$I->see('Lindfield, All Saints');
	$I->dontSee('Hammerwood, St Stephen');
    }

    public function canOnlySeeActiveMembersOnAnnualReport(AcceptanceTester $I)
    {
	$I->amOnPage('/index.php/component/memberdatabase/?view=annualreport');
        $I->comment('I see active members');
	$I->see('Spencer, Jonathan');
        $I->comment('I do not see non-members');
	$I->dontSee('Abbott, Deborah');
        $I->comment('I do not see deceased members'); 
	$I->dontSee('Daughtry, Anne');
    }

    public function canSeeCorrectCorrespondanceEmailAddressOnCSVExport(AcceptanceTester $I)
    {
	$I->amOnPage('/index.php?option=com_memberdatabase&view=annualreport&layout=emailaddressescsv&print=0&correspFlag=1&tmpl=com_memberdatabase');
        $I->comment('I see member\'s own email address when preferred tower correspondance email address is not specified');
	$I->see('peter@rabbit.com');
        $I->comment('I see preferred mail address when specified');
	$I->see('test_corresp@testmail.com');
        $I->comment('I do not see member\'s own email address when preferred tower correspondance email address is specified');
	$I->dontSee('mini@mouse.com');
        $I->comment('I see preferred tower correspondance email address');
	$I->see('test_corresp@testmail.com');
    }
    
    public function canModifyMemberAttributes(AcceptanceTester $I)
    {
	$I->amGoingTo('check that I can modify attributes of a member');
	$I->amOnPage('/index.php/component/memberdatabase?view=members');
	$I->see('Blogs, Fred (721)');
	$I->click('Blogs, Fred (721)');
	$I->fillField('jform[forenames]', 'F');
	$I->fillField('jform[email]', 'freddys@newemail.com');
	$I->click([
            'class' => 'btn-save-close'
        ]);
    $I->see('Blogs, F (721)');
    $I->dontSee('Blogs, Fred (721)');
    $I->click('Blogs, F (721)');
    $I->seeInField('jform[email]','freddys@newemail.com');
    }
    
    public function canCreateIndividualInvoice(AcceptanceTester $I)
    {
	$I->amGoingTo('check that I can create an individual invoice for a member');
	$I->amOnPage('/index.php/component/memberdatabase?view=members');
	$I->see('Blogs, Fred (630)');
	$I->click('Blogs, Fred (630)');
    //$I->see('Invoices');
	$I->dontSee('£8.00');
	$I->click([
            'class' => 'btn-create-invoice'
        ]);
    $I->see('£8.00');
    $I->dontSee('Invoice already exists for this member');
    $I->click([
            'class' => 'btn-create-invoice'
        ]);
    $I->see('Invoice already exists for this member');

    }

}
