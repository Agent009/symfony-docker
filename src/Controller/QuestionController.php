<?php

use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class QuestionController extends BaseController
{
    public function __construct(LoggerInterface $logger)
    {
        parent::__construct($logger);
    }

    /**
     * @Route("/")
     */
    public function homepage() : Response
    {
        return new Response('What a bewitching controller we have conjured!');
    }

    /**
     * @Route("/questions/{slug}")
     */
    public function show($slug) : Response
    {
        $answers = [
            'Make sure your cat is sitting purrrfectly still ?',
            'Honestly, I like furry shoes better than MY cat',
            'Maybe... try saying the spell backwards?',
        ];
        return $this->render('question/show.html.twig', [
            'question' => ucwords(str_replace('-', ' ', $slug)),
            'answers'  => $answers,
        ]);
    }
}
