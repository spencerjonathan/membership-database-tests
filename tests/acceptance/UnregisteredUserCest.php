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

        $I->comment('I can populate fields and submit');
        $I->selectOption('jform[title]', 'Mr');
        $I->fillField('jform[forenames]', 'Fredrick');
        $I->fillField('jform[surname]', 'Jones');
        $I->fillField('jform[email]', 'fred@jones.com');
        $I->click([
            'class' => 'btn-save-newmember'
        ]);
        $I->dontSee('Create record not permitted');
        $I->see('You\'re on the default page for newmember');

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
        
        $I->seeInField('#jform_forenames', 'Fredrick');
        $I->seeInField('#jform_email', 'fred@jones.com');
        $I->seeInField('#jform_surname', 'Jones');
        
        $I->fillField('jform[address1]', 'Number 1 Toy Town');
        $I->selectOption('jform[tower_id]', 'Lindfield, All Saints');
        $I->selectOption('jform[member_type_id]', 'Adult');
        $I->selectOption('jform[insurance_group]', '16-70');
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
        
        $I->see('You\'re on the default page for newmember');
        
        
    }
}
