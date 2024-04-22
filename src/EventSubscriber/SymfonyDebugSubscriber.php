<?php
namespace App\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\HttpKernel\KernelInterface;

readonly class SymfonyDebugSubscriber implements EventSubscriberInterface
{
    public function __construct(private KernelInterface $kernel)
    {
    }

    public static function getSubscribedEvents(): array
    {
        return [
            KernelEvents::EXCEPTION => 'onKernelResponse',
        ];
    }

    // ...

    public function onKernelResponse(ResponseEvent $event) : void
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
