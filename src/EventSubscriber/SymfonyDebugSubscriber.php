<?php
namespace App\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class SymfonyDebugSubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        // return the subscribed events, their methods and priorities
        return [
            KernelEvents::EXCEPTION => [
                ['onKernelResponse', 0],
            ],
        ];
    }

    // ...

    public function onKernelResponse(ResponseEvent $event)
    {
        if (!$this->kernel->isDebug()) {
            return;
        }

        $request = $event->getRequest();
        if (!$request->isXmlHttpRequest()) {
            return;
        }

        $response = $event->getResponse();
        $response->headers->set('Symfony-Debug-Toolbar-Replace', 1);
    }
}
