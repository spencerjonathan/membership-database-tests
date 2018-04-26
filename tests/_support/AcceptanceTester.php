<?php


/**
 * Inherited Methods
 * @method void wantToTest($text)
 * @method void wantTo($text)
 * @method void execute($callable)
 * @method void expectTo($prediction)
 * @method void expect($prediction)
 * @method void amGoingTo($argumentation)
 * @method void am($role)
 * @method void lookForwardTo($achieveValue)
 * @method void comment($description)
 * @method \Codeception\Lib\Friend haveFriend($name, $actorClass = NULL)
 *
 * @SuppressWarnings(PHPMD)
*/
class AcceptanceTester extends \Codeception\Actor
{
    use _generated\AcceptanceTesterActions;

   /**
    * Define custom actions here
    */

    public function login(AcceptanceTester $I, $user)
    {
        $I->amOnPage('/index.php/login');
        $I->comment('Fill Username Text Field');
        $I->fillField('#username', $user);
        $I->comment('Fill Password Text Field');
        $I->fillField('#password', $user);
        $I->comment('I click Login button');
        $I->click('Log in');
        $I->comment('I see my profile');
        $I->see('Profile');
    }
}
