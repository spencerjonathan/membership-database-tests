<?php

class UnregisteredUserCest
{

    public function canRegisterAsANewUser(AcceptanceTester $I)
    {
        $I->comment('I only see initial fields');
        $I->amOnPage('/index.php/component/memberdatabase/?view=newmember&layout=edit');
        $I->see('Title');
        $I->see('Forenames');
        $I->see('Surname');
        $I->see('Email Address');
        $I->dontSee('Address 1');
        $I->dontSee('Tower');

        $I->see('Thankyou for applying for membership online.  Before you start, you will need your own email address and the email addresses of the two association members proposing you for membership.');

        $I->comment('I can populate fields and submit');
        $I->selectOption('jform[title]', 'Mr');
        $I->fillField('jform[forenames]', 'Fredrick');
        $I->fillField('jform[surname]', 'Jones');
        $I->fillField('jform[email]', 'fred@jones.com');
        $I->click([
            'class' => 'btn-save-newmember'
        ]);
        $I->dontSee('Create record not permitted');
        $I->see('Thank you for starting the membership application process.  A link has been sent to you');

        $I->comment('I can\'t start application twice');
        $I->amOnPage('/index.php/component/memberdatabase/?view=newmember&layout=edit');
        $I->comment('I can populate fields and submit');
        $I->selectOption('jform[title]', 'Mr');
        $I->fillField('jform[forenames]', 'Fredrick');
        $I->fillField('jform[surname]', 'Jones');
        $I->fillField('jform[email]', 'fred@jones.com');
        $I->click([
            'class' => 'btn-save-newmember'
        ]);
        $I->dontSee('Create record not permitted');
        $I->dontSee('Thank you for starting the membership application process.  A link has been sent to you');
        $I->see('A membership application request has already been submitted using this email address');


        $I->comment('Submitting initial details generates record in new member table');
        $I->seeInDatabase('c1jr0_md_new_member', array(
            'email' => 'fred@jones.com'
        ));

        $I->comment('Submitting initial details generates a token');
        $I->seeInDatabase('c1jr0_md_member_token', array(
            'email' => 'fred@jones.com'
        ));

        $token = $I->grabFromDatabase('c1jr0_md_member_token', 'hash_token', array(
            'email' => 'fred@jones.com'
        ));
        $record_id = $I->grabFromDatabase('c1jr0_md_new_member', 'id', array(
            'email' => 'fred@jones.com'
        ));
        $I->comment('Token created for new member = ' . $token);
        $I->comment('Record created for new member with id = ' . $record_id);

        $I->comment('I can use the token to populate the rest of the membership details');
        $I->amOnPage('/index.php/component/memberdatabase/?view=newmember&layout=edit&stage=main&token=' . $token);
        
        $I->dontSee('Thankyou for applying for membership online.');
        $I->dontSee('Notes');

        $I->seeInField('#jform_forenames', 'Fredrick');
        $I->seeInField('#jform_email', 'fred@jones.com');
        $I->seeInField('#jform_surname', 'Jones');
        
        $I->fillField('jform[address1]', 'Number 1 Toy Town');
        $I->selectOption('jform[tower_id]', 'Lindfield, All Saints');
        $I->selectOption('jform[member_type_id]', 'Adult');
        $I->selectOption('jform[insurance_group]', '16-24');
        $I->click([
            'class' => 'btn-save-newmember'
        ]);
        
        $I->seeInDatabase('c1jr0_md_new_member', array(
            'email' => 'fred@jones.com',
            'address1' => 'Number 1 Toy Town'
        ));
        
        $I->see('Proposers');
        
        $I->fillField('jform[proposer_email]', 'jm@abc.com');
        $I->fillField('jform[seconder_email]', 'fred@blogs.com');
        
        $I->click([
            'class' => 'btn-save-newmember'
        ]);
        
        $I->see('No current members have email address jm@abc.com');
        $I->see('Proposers');
        
        $I->fillField('jform[proposer_email]', 'fred@blogs.com');
        
        $I->click([
            'class' => 'btn-save-newmember'
        ]);
        
        $I->see('Proposer and Seconder email addresses must be different');
        $I->see('Proposers');
        
        $I->fillField('jform[proposer_email]', 'peter@rabbit.com');
        
        $I->click([
            'class' => 'btn-save-newmember'
        ]);
        
        $I->see('Thank you for submitting your membership application.  An email has been sent to your proposer and seconder to ask them to acknowledge that they support your application.');

        // Check that I can't modify record after I've submitted proposers
        $I->amOnPage('/index.php/component/memberdatabase/?view=newmember&layout=edit&stage=main&token=' . $token);
        $I->see('You have already submitted your application');

        // Check that proposers can acknowledge their proposal
        $proposer_id = $I->grabFromDatabase('c1jr0_md_new_member_proposer', 'id', array('newmember_id' => $record_id, ));
        $proposer_tokens = $I->grabColumnFromDatabase('c1jr0_md_new_member_proposer', 'hash_token', array('newmember_id' => $record_id, ));

        $I->comment("Proposer_tokens: " . json_encode($proposer_tokens));
        //$this->assertEquals(2, sizeof($proposer_tokens), "Should be 2 newmember_proposer records");

        $I->amOnPage('/index.php/component/memberdatabase/?view=newmemberproposer&token=' . $proposer_tokens[0]);

        $I->see('Verify New Member Proposal');
        $I->see('Do you wish to propose Fredrick Jones of tower Lindfield');

        $I->selectOption('jform[approved_flag]', '1');

        $I->click([
            'class' => 'btn-save-newmemberproposer'
        ]);

        $I->see('Item saved.');
        $I->see('Thankyou. Your nomination has been submitted.');
        
        $I->amOnPage('/index.php/component/memberdatabase/?view=newmemberproposer&token=' . $proposer_tokens[1]);

        $I->see('Verify New Member Proposal');
        $I->see('Do you wish to propose Fredrick Jones of tower Lindfield');

        $I->selectOption('jform[approved_flag]', '1');

        $I->click([
            'class' => 'btn-save-newmemberproposer'
        ]);

        $I->see('Item saved.');
        $I->see('Thankyou. Your nomination has been submitted.');

        $member_id = $I->grabFromDatabase('c1jr0_md_new_member_proposer', 'member_id', array('newmember_id' => $record_id));    
        $I->comment("Member Id is: " . $member_id);

        $I->seeInDatabase('c1jr0_md_member', array(
            'id' => $member_id,
            'email' => 'fred@jones.com',
            'forenames' => 'Fredrick',
            'surname' => 'Jones',
            'tower_id' => 82
        ));
        
        $I->comment("Check that you can't acknowledge that you're a proposer twice.");
        $I->amOnPage('/index.php/component/memberdatabase/?view=newmemberproposer&token=' . $proposer_tokens[1]);
        $I->see('You have already responded.');
        $I->dontSee('Submit');

    }
    
    public function canEditOwnRecord(AcceptanceTester $I) {
        $I->amGoingTo('check that I can modify attributes of my membership record');
	    $I->amOnPage('/index.php?option=com_memberdatabase&view=requestlink');
	    $I->see('Request Access To Your Personal Data');
	    $I->fillField('email', 'freddy@blogsy.com');
	    
	    $I->click([
            'class' => 'btn-submit-request'
        ]);
	    $token = $I->grabFromDatabase('c1jr0_md_member_token', 'hash_token', array(
            'email' => 'freddy@blogsy.com'
        ));
        $I->amOnPage('/index.php/component/memberdatabase/?view=members&token=' . $token);
        $I->see('Blogsy, Freddy (54)');
        $I->click('Blogsy, Freddy (54)');
        $I->seeInField('jform[email]','freddy@blogsy.com');
        $I->selectOption('jform[newsletters]', 'Postal');
        $I->fillField('jform[forenames]', 'Freddy Bob');
        $I->click([
            'class' => 'btn-save-and-verify'
        ]);
        $I->see('Blogsy, Freddy Bob (54)');
        $I->click('Blogsy, Freddy Bob (54)');
        $I->seeInField('jform[newsletters]','Postal');
 	    
    }
}
